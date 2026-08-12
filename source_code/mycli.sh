#!/bin/bash
# ============================================================
#  mycoinflip Admin CLI Tool
#  Usage: ./mycli.sh [command]
# ============================================================

COMPOSE_FILE="/opt/mycoinflips/source_code/docker-compose.prod.yml"
PROJECT_DIR="/opt/mycoinflips/source_code"
DB_CONTAINER="mycoinflip-db-1"
SERVER_CONTAINER="mycoinflip-server-1"
FRONTEND_CONTAINER="mycoinflip-frontend-1"

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ──────────────────────────────────────────────────
info()    { echo -e "${CYAN}ℹ  $*${RESET}"; }
success() { echo -e "${GREEN}✔  $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠  $*${RESET}"; }
error()   { echo -e "${RED}✘  $*${RESET}" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${RESET}"; echo -e "${BOLD}   $*${RESET}"; echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}\n"; }

confirm() {
  read -rp "$(echo -e "${YELLOW}  ⚠  $1 [y/N]: ${RESET}")" ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

# ── DB Helper ─────────────────────────────────────────────────
db_query() {
  # Reads POSTGRES_USER and POSTGRES_DB from the running container's env
  local PGUSER
  PGUSER=$(docker exec "$DB_CONTAINER" env | grep POSTGRES_USER | cut -d= -f2)
  local PGDB
  PGDB=$(docker exec "$DB_CONTAINER" env | grep POSTGRES_DB | cut -d= -f2)
  docker exec -i "$DB_CONTAINER" psql -U "$PGUSER" -d "$PGDB" -t -A -c "$1"
}

# ════════════════════════════════════════════════════════════
# COMMAND: status
# ════════════════════════════════════════════════════════════
cmd_status() {
  header "Container Status"
  cd "$PROJECT_DIR" || exit 1
  docker compose -f "$COMPOSE_FILE" ps
}

# ════════════════════════════════════════════════════════════
# COMMAND: logs
# ════════════════════════════════════════════════════════════
cmd_logs() {
  local service="${1:-server}"
  header "Logs: $service (last 100 lines)"
  cd "$PROJECT_DIR" || exit 1
  docker compose -f "$COMPOSE_FILE" logs --tail=100 "$service"
}

# ════════════════════════════════════════════════════════════
# COMMAND: restart
# ════════════════════════════════════════════════════════════
cmd_restart() {
  local service="${1:-}"
  if [[ -z "$service" ]]; then
    confirm "Restart ALL containers?" || { warn "Aborted."; return; }
    header "Restarting all containers..."
    cd "$PROJECT_DIR" && docker compose -f "$COMPOSE_FILE" restart
  else
    confirm "Restart '$service' container?" || { warn "Aborted."; return; }
    header "Restarting $service..."
    cd "$PROJECT_DIR" && docker compose -f "$COMPOSE_FILE" restart "$service"
  fi
  success "Done."
}

# ════════════════════════════════════════════════════════════
# COMMAND: rebuild
# ════════════════════════════════════════════════════════════
cmd_rebuild() {
  local service="${1:-}"
  if [[ -z "$service" ]]; then
    confirm "Rebuild and redeploy ALL containers? This will cause a brief downtime." || { warn "Aborted."; return; }
    header "Rebuilding all containers..."
    cd "$PROJECT_DIR" || exit 1
    docker compose -f "$COMPOSE_FILE" build && docker compose -f "$COMPOSE_FILE" up -d
  else
    confirm "Rebuild and redeploy '$service' container?" || { warn "Aborted."; return; }
    header "Rebuilding $service..."
    cd "$PROJECT_DIR" || exit 1
    docker compose -f "$COMPOSE_FILE" build "$service" && docker compose -f "$COMPOSE_FILE" up -d "$service"
  fi
  success "Done."
}

# ════════════════════════════════════════════════════════════
# COMMAND: stop / start
# ════════════════════════════════════════════════════════════
cmd_stop() {
  local service="${1:-}"
  confirm "Stop ${service:-ALL} containers?" || { warn "Aborted."; return; }
  cd "$PROJECT_DIR" || exit 1
  if [[ -n "$service" ]]; then
    docker compose -f "$COMPOSE_FILE" stop "$service"
  else
    docker compose -f "$COMPOSE_FILE" stop
  fi
  success "Stopped."
}

cmd_start() {
  local service="${1:-}"
  header "Starting ${service:-all} containers..."
  cd "$PROJECT_DIR" || exit 1
  if [[ -n "$service" ]]; then
    docker compose -f "$COMPOSE_FILE" start "$service"
  else
    docker compose -f "$COMPOSE_FILE" up -d
  fi
  success "Running."
}

# ════════════════════════════════════════════════════════════
# COMMAND: revoke
# ════════════════════════════════════════════════════════════
# JWT is stateless — to force-logout we rotate a per-user token_version
# counter stored in the DB. The auth middleware checks it on every request.
# ════════════════════════════════════════════════════════════
cmd_revoke() {
  header "Revoke Admin / Superadmin Session"

  # List ADMIN and SUPERUSER accounts
  local raw
  raw=$(db_query "SELECT id, email, role FROM \"User\" WHERE role IN ('ADMIN','SUPERUSER') ORDER BY role, email;")

  if [[ -z "$raw" ]]; then
    warn "No ADMIN or SUPERUSER accounts found."
    return
  fi

  echo -e "${BOLD}  #  Role         Email${RESET}"
  echo "  ─────────────────────────────────────────"
  local i=1
  declare -a IDS EMAILS ROLES
  while IFS="|" read -r uid email role; do
    printf "  ${CYAN}%-3s${RESET} %-12s %s\n" "$i" "$role" "$email"
    IDS+=( "$uid" )
    EMAILS+=( "$email" )
    ROLES+=( "$role" )
    ((i++))
  done <<< "$raw"

  echo ""
  read -rp "$(echo -e "${YELLOW}  Enter number to revoke (or 'q' to quit): ${RESET}")" choice

  [[ "$choice" == "q" ]] && { warn "Aborted."; return; }

  local idx=$(( choice - 1 ))
  if [[ $idx -lt 0 || $idx -ge ${#IDS[@]} ]]; then
    error "Invalid selection."
    return 1
  fi

  local target_id="${IDS[$idx]}"
  local target_email="${EMAILS[$idx]}"
  local target_role="${ROLES[$idx]}"

  confirm "Revoke ALL active sessions for ${target_role} '${target_email}'?" || { warn "Aborted."; return; }

  # Increment tokenVersion in DB — the auth middleware will reject any JWT
  # containing the old tokenVersion value
  local result
  result=$(db_query "UPDATE \"User\" SET \"tokenVersion\" = COALESCE(\"tokenVersion\", 0) + 1 WHERE id = '${target_id}' RETURNING email, \"tokenVersion\";")

  if [[ -n "$result" ]]; then
    success "Sessions revoked for '${target_email}'. They will be logged out on their next request."
    info  "New token version: $(echo "$result" | awk -F'|' '{print $2}')"
  else
    error "Failed to revoke sessions. The 'tokenVersion' column may not exist yet."
    warn  "Run: ./mycli.sh migrate-session"
  fi
}

# ════════════════════════════════════════════════════════════
# COMMAND: migrate-session
# Adds the tokenVersion column if it doesn't exist yet
# ════════════════════════════════════════════════════════════
cmd_migrate_session() {
  header "Migrate: Add tokenVersion to User table"
  info "Checking if 'tokenVersion' column exists..."
  local exists
  exists=$(db_query "SELECT COUNT(*) FROM information_schema.columns WHERE table_name='User' AND column_name='tokenVersion';")
  if [[ "$exists" -gt 0 ]]; then
    success "Column already exists. Nothing to do."
    return
  fi

  info "Adding 'tokenVersion' column..."
  db_query "ALTER TABLE \"User\" ADD COLUMN \"tokenVersion\" INTEGER NOT NULL DEFAULT 0;"
  success "Column added. Now update the auth middleware to enforce it (./mycli.sh help)."
}

# ════════════════════════════════════════════════════════════
# COMMAND: list-admins
# ════════════════════════════════════════════════════════════
cmd_list_admins() {
  header "Admin Accounts"
  local raw
  raw=$(db_query "SELECT email, role, status, \"createdAt\" FROM \"User\" WHERE role IN ('ADMIN','SUPERUSER') ORDER BY role, email;")
  if [[ -z "$raw" ]]; then
    warn "No admins found."
    return
  fi
  echo -e "${BOLD}  Email                         Role         Status    Created${RESET}"
  echo "  ──────────────────────────────────────────────────────────────────"
  while IFS="|" read -r email role status created; do
    printf "  %-30s %-12s %-9s %s\n" "$email" "$role" "$status" "${created%%T*}"
  done <<< "$raw"
}

# ════════════════════════════════════════════════════════════
# COMMAND: shell
# ════════════════════════════════════════════════════════════
cmd_shell() {
  local target="${1:-server}"
  local container
  case "$target" in
    db|database)   container="$DB_CONTAINER" ;;
    server|api)    container="$SERVER_CONTAINER" ;;
    frontend|web)  container="$FRONTEND_CONTAINER" ;;
    *) error "Unknown target: $target. Use: db / server / frontend"; return 1 ;;
  esac
  header "Shell: $container"
  warn "Type 'exit' to leave the shell."
  docker exec -it "$container" /bin/sh
}

# ════════════════════════════════════════════════════════════
# COMMAND: dbshell
# ════════════════════════════════════════════════════════════
cmd_dbshell() {
  header "PostgreSQL Shell"
  local PGUSER
  PGUSER=$(docker exec "$DB_CONTAINER" env | grep POSTGRES_USER | cut -d= -f2)
  local PGDB
  PGDB=$(docker exec "$DB_CONTAINER" env | grep POSTGRES_DB | cut -d= -f2)
  warn "Type '\\q' to quit the psql shell."
  docker exec -it "$DB_CONTAINER" psql -U "$PGUSER" -d "$PGDB"
}

# ════════════════════════════════════════════════════════════
# COMMAND: restore
# ════════════════════════════════════════════════════════════
cmd_restore() {
  header "Automated Restore"
  confirm "Run auto restore? This will rebuild containers and restore DB & uploaded files." || { warn "Aborted."; return; }
  cd "$PROJECT_DIR" || exit 1
  bash ./restore.sh "$@"
}

# ════════════════════════════════════════════════════════════
# COMMAND: help
# ════════════════════════════════════════════════════════════
cmd_help() {
  echo -e ""
  echo -e "${BOLD}${CYAN}  mycoinflip Admin CLI${RESET}"
  echo -e "  ─────────────────────────────────────────────────────"
  echo -e ""
  echo -e "  ${BOLD}Container Management${RESET}"
  echo -e "    ${GREEN}status${RESET}                       — Show status of all containers"
  echo -e "    ${GREEN}start  [service]${RESET}             — Start all, or a specific service"
  echo -e "    ${GREEN}stop   [service]${RESET}             — Stop all, or a specific service"
  echo -e "    ${GREEN}restart [service]${RESET}            — Restart all, or a specific service"
  echo -e "    ${GREEN}rebuild [service]${RESET}            — Rebuild image & redeploy (frontend, server, db)"
  echo -e "    ${GREEN}restore [db.sql] [uploads/]${RESET}  — Auto-restore containers, PostgreSQL DB, and uploaded files"
  echo -e "    ${GREEN}logs   [service]${RESET}             — Tail logs (default: server)"
  echo -e ""
  echo -e "  ${BOLD}Session Management${RESET}"
  echo -e "    ${GREEN}revoke${RESET}                       — Revoke all sessions for an admin/superadmin"
  echo -e "    ${GREEN}list-admins${RESET}                  — List all admin & superadmin accounts"
  echo -e "    ${GREEN}migrate-session${RESET}              — (One-time) Add tokenVersion column to DB"
  echo -e ""
  echo -e "  ${BOLD}Shells${RESET}"
  echo -e "    ${GREEN}shell  [server|frontend|db]${RESET}  — Open a shell inside a container"
  echo -e "    ${GREEN}dbshell${RESET}                      — Open the PostgreSQL interactive shell"
  echo -e ""
  echo -e "  ${BOLD}Examples${RESET}"
  echo -e "    ./mycli.sh status"
  echo -e "    ./mycli.sh restore"
  echo -e "    ./mycli.sh rebuild frontend"
  echo -e "    ./mycli.sh logs server"
  echo -e "    ./mycli.sh revoke"
  echo -e ""
}

# ════════════════════════════════════════════════════════════
# MAIN DISPATCHER
# ════════════════════════════════════════════════════════════
main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    status)           cmd_status "$@" ;;
    logs)             cmd_logs "$@" ;;
    start)            cmd_start "$@" ;;
    stop)             cmd_stop "$@" ;;
    restart)          cmd_restart "$@" ;;
    rebuild)          cmd_rebuild "$@" ;;
    restore)          cmd_restore "$@" ;;
    revoke)           cmd_revoke "$@" ;;
    list-admins)      cmd_list_admins "$@" ;;
    migrate-session)  cmd_migrate_session "$@" ;;
    shell)            cmd_shell "$@" ;;
    dbshell)          cmd_dbshell "$@" ;;
    help|--help|-h)   cmd_help ;;
    *)
      error "Unknown command: '$cmd'"
      cmd_help
      exit 1
      ;;
  esac
}

main "$@"

