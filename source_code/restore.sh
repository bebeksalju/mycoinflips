#!/bin/bash
# ==============================================================================
#  MyCoinFlip Automated Restore Script (Production Mode)
#  Usage: ./restore.sh [path_to_db_dump.sql] [path_to_uploads_dir]
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}ℹ  $*${RESET}"; }
success() { echo -e "${GREEN}✔  $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠  $*${RESET}"; }
error()   { echo -e "${RED}✘  $*${RESET}" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════════════════════════${RESET}"; echo -e "${BOLD}   $*${RESET}"; echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${RESET}\n"; }

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${PROJECT_DIR}/docker-compose.prod.yml"

header "Automated Restore Process - MyCOINFLIP"

# 1. Check .env file
if [ -f "${PROJECT_DIR}/.env" ]; then
    info "Loading environment variables from .env..."
    export $(grep -v '^#' "${PROJECT_DIR}/.env" | xargs)
else
    error ".env file not found in ${PROJECT_DIR}!"
    exit 1
fi

POSTGRES_USER="${POSTGRES_USER:-myflipcoin}"
POSTGRES_DB="${POSTGRES_DB:-mycoinflips}"

# 2. Locate DB Dump file
DB_DUMP_FILE="${1}"
if [ -z "$DB_DUMP_FILE" ]; then
    # Auto-detect best dump file
    if [ -f "/opt/mycoinflips/db_backup/db_dump.sql" ]; then
        DB_DUMP_FILE="/opt/mycoinflips/db_backup/db_dump.sql"
    elif [ -f "${PROJECT_DIR}/db_backup/db_dump.sql" ]; then
        DB_DUMP_FILE="${PROJECT_DIR}/db_backup/db_dump.sql"
    elif [ -f "${PROJECT_DIR}/backups/github-backup-repo/db_backup/db_dump.sql" ]; then
        DB_DUMP_FILE="${PROJECT_DIR}/backups/github-backup-repo/db_backup/db_dump.sql"
    fi
fi

if [ -z "$DB_DUMP_FILE" ] || [ ! -f "$DB_DUMP_FILE" ]; then
    error "No database dump file found!"
    echo "Usage: ./restore.sh [path/to/db_dump.sql] [path/to/uploads_backup]"
    exit 1
fi

info "Using Database Dump: ${DB_DUMP_FILE}"

# 3. Locate Uploads Backup folder
UPLOADS_BACKUP_DIR="${2}"
if [ -z "$UPLOADS_BACKUP_DIR" ]; then
    if [ -d "/opt/mycoinflips/uploads_backup" ]; then
        UPLOADS_BACKUP_DIR="/opt/mycoinflips/uploads_backup"
    elif [ -d "${PROJECT_DIR}/uploads_backup" ]; then
        UPLOADS_BACKUP_DIR="${PROJECT_DIR}/uploads_backup"
    elif [ -d "${PROJECT_DIR}/backups/github-backup-repo/uploads_backup" ]; then
        UPLOADS_BACKUP_DIR="${PROJECT_DIR}/backups/github-backup-repo/uploads_backup"
    fi
fi

if [ -n "$UPLOADS_BACKUP_DIR" ] && [ -d "$UPLOADS_BACKUP_DIR" ]; then
    info "Using Uploads Backup Directory: ${UPLOADS_BACKUP_DIR}"
else
    warn "Uploads backup directory not found. Skipping file upload restore."
fi

# 4. Prepare SSL Directory & Dummy Certificates if missing
info "Checking SSL certificate configuration..."
CERT_DIR="${PROJECT_DIR}/certbot/conf/live/mycoinflips.com"
mkdir -p "${CERT_DIR}"
if [ ! -f "${CERT_DIR}/fullchain.pem" ] || [ ! -f "${CERT_DIR}/privkey.pem" ]; then
    warn "SSL certificates missing! Generating self-signed temporary certificates..."
    openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
        -keyout "${CERT_DIR}/privkey.pem" \
        -out "${CERT_DIR}/fullchain.pem" \
        -subj '/CN=mycoinflips.com' 2>/dev/null
    success "Temporary SSL certificates generated."
else
    success "SSL certificates found."
fi

# 5. Build and launch Docker containers
header "Phase 1: Starting Docker Production Containers"
cd "${PROJECT_DIR}"
docker compose -f "${COMPOSE_FILE}" up --build -d

# Wait for postgres DB container to become healthy
info "Waiting for database container to be healthy..."
max_retries=30
retry=0
while [ $retry -lt $max_retries ]; do
    DB_HEALTH=$(docker inspect --format='{{json .State.Health.Status}}' $(docker compose -f "${COMPOSE_FILE}" ps -q db 2>/dev/null) 2>/dev/null || echo "unhealthy")
    if [ "$DB_HEALTH" == "\"healthy\"" ]; then
        success "Database container is healthy and ready!"
        break
    fi
    sleep 2
    retry=$((retry + 1))
done

if [ $retry -eq $max_retries ]; then
    error "Database container failed to reach healthy state!"
    exit 1
fi

# 6. Clean Database Restore
header "Phase 2: Restoring Database (PostgreSQL)"
info "Dropping existing public schema for a clean import..."
docker compose -f "${COMPOSE_FILE}" exec -T db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; ALTER SCHEMA public OWNER TO \"${POSTGRES_USER}\";" > /dev/null

info "Importing dump SQL into PostgreSQL database..."
docker compose -f "${COMPOSE_FILE}" exec -T db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" < "${DB_DUMP_FILE}" > /dev/null
success "Database restored successfully from ${DB_DUMP_FILE}!"

# 7. Restore Upload Files (KYC & Transfer Proofs)
if [ -n "$UPLOADS_BACKUP_DIR" ] && [ -d "$UPLOADS_BACKUP_DIR" ]; then
    header "Phase 3: Restoring Uploaded Media Files"
    SERVER_CONTAINER=$(docker compose -f "${COMPOSE_FILE}" ps -q server)
    if [ -n "$SERVER_CONTAINER" ]; then
        info "Copying KYC & Proof images into server uploads volume..."
        docker run --rm --volumes-from "$SERVER_CONTAINER" -v "${UPLOADS_BACKUP_DIR}":/backup_host alpine sh -c \
            "mkdir -p /app/uploads/kyc /app/uploads/proofs && \
             if [ -d /backup_host/kyc ]; then cp -rp /backup_host/kyc/* /app/uploads/kyc/ 2>/dev/null || true; fi && \
             if [ -d /backup_host/proofs ]; then cp -rp /backup_host/proofs/* /app/uploads/proofs/ 2>/dev/null || true; fi"
        success "Uploaded media files restored successfully!"
    else
        warn "Server container not running. Skipping uploads restoration."
    fi
fi

# 8. Restart Backend Server
header "Phase 4: Restarting Backend API Server"
info "Restarting server container to refresh database connection pool..."
docker compose -f "${COMPOSE_FILE}" restart server > /dev/null
success "Server container restarted successfully!"

# 9. Verification & Summary
header "Restoration Summary & Status"
docker compose -f "${COMPOSE_FILE}" ps

echo ""
info "Verifying restored data count in Database:"
docker compose -f "${COMPOSE_FILE}" exec -T db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -c "SELECT 'User' as table, count(*) FROM \"User\" UNION ALL SELECT 'Transaction', count(*) FROM \"Transaction\" UNION ALL SELECT 'Kyc', count(*) FROM \"Kyc\";"

echo ""
success "=============================================================="
success " 🎉 AUTO RESTORE COMPLETED SUCCESSFULLY!"
success "=============================================================="
