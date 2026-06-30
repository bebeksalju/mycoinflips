#!/bin/bash
set -euo pipefail

# ============================================================
#  MyCoinFlip - Full Backup Script
#  Backs up: source code, .env, database, volumes, images,
#            nginx config, and SSL certificates
# ============================================================

# --- Configuration ---
PROJECT_DIR="/opt/mycoinflip"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_ROOT="/opt/mycoinflip-backups"
BACKUP_DIR="${BACKUP_ROOT}/backup_${TIMESTAMP}"
ARCHIVE_NAME="mycoinflip_full_backup_${TIMESTAMP}.tar.gz"

# Docker container/service names (from docker-compose.prod.yml)
DB_CONTAINER="mycoinflip_db_1"
COMPOSE_FILE="docker-compose.prod.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Pre-flight checks ---
echo ""
echo "=============================================="
echo "  MyCoinFlip Full Backup"
echo "  $(date)"
echo "=============================================="
echo ""

if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not in PATH."
    exit 1
fi

if ! docker ps &> /dev/null; then
    log_error "Cannot connect to Docker daemon. Are you root?"
    exit 1
fi

# Create backup directory structure
mkdir -p "${BACKUP_DIR}"/{source_code,database,volumes,images,configs}
log_info "Backup directory: ${BACKUP_DIR}"

# ============================================================
# 1. BACKUP SOURCE CODE (including .env files)
# ============================================================
log_info "Step 1/6: Backing up source code & environment files..."

rsync -a --exclude='node_modules' \
         --exclude='backups' \
         --exclude='.git' \
         --exclude='dist' \
         --exclude='build' \
         "${PROJECT_DIR}/" "${BACKUP_DIR}/source_code/"

# Verify .env was included
if [[ -f "${BACKUP_DIR}/source_code/.env" ]]; then
    log_success "Source code backed up (including .env)"
else
    log_warn ".env file not found in backup!"
fi

# Also create a standalone env backup for safety
cp "${PROJECT_DIR}/.env" "${BACKUP_DIR}/configs/env_backup_${TIMESTAMP}" 2>/dev/null || true
cp "${PROJECT_DIR}/.env.example" "${BACKUP_DIR}/configs/env_example_backup" 2>/dev/null || true
log_success "Environment files backed up separately to configs/"

# ============================================================
# 2. BACKUP DOCKER COMPOSE FILES
# ============================================================
log_info "Step 2/6: Backing up Docker Compose configurations..."

cp "${PROJECT_DIR}/docker-compose.yml" "${BACKUP_DIR}/configs/" 2>/dev/null || true
cp "${PROJECT_DIR}/docker-compose.prod.yml" "${BACKUP_DIR}/configs/" 2>/dev/null || true
log_success "Docker Compose files backed up"

# ============================================================
# 3. BACKUP DATABASE (pg_dump)
# ============================================================
log_info "Step 3/6: Backing up PostgreSQL database..."

# Source the .env to get credentials
set -a
source "${PROJECT_DIR}/.env"
set +a

if docker ps --format '{{.Names}}' | grep -q "${DB_CONTAINER}"; then
    # Create both custom format (for flexible restore) and plain SQL (for readability)
    docker exec "${DB_CONTAINER}" pg_dump \
        -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" \
        --clean --if-exists \
        -F c \
        -f /tmp/db_backup.dump

    docker cp "${DB_CONTAINER}:/tmp/db_backup.dump" \
        "${BACKUP_DIR}/database/mycoinflips_${TIMESTAMP}.dump"

    # Also create plain SQL backup
    docker exec "${DB_CONTAINER}" pg_dump \
        -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" \
        --clean --if-exists \
        -F p \
        -f /tmp/db_backup.sql

    docker cp "${DB_CONTAINER}:/tmp/db_backup.sql" \
        "${BACKUP_DIR}/database/mycoinflips_${TIMESTAMP}.sql"

    # Clean up temp files in container
    docker exec "${DB_CONTAINER}" rm -f /tmp/db_backup.dump /tmp/db_backup.sql

    # Get row counts for verification
    log_info "Database table summary:"
    docker exec "${DB_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c \
        "SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" \
        2>/dev/null || true

    log_success "Database backed up (.dump + .sql)"
else
    log_error "Database container '${DB_CONTAINER}' is not running! Skipping DB backup."
fi

# ============================================================
# 4. BACKUP DOCKER VOLUMES
# ============================================================
log_info "Step 4/6: Backing up Docker volumes..."

# Backup postgres_data volume
log_info "  → Backing up mycoinflip_postgres_data..."
docker run --rm \
    -v mycoinflip_postgres_data:/source:ro \
    -v "${BACKUP_DIR}/volumes":/backup \
    alpine tar czf /backup/postgres_data.tar.gz -C /source . \
    && log_success "  postgres_data volume backed up" \
    || log_warn "  Failed to backup postgres_data volume"

# Backup uploads_data volume
log_info "  → Backing up mycoinflip_uploads_data..."
docker run --rm \
    -v mycoinflip_uploads_data:/source:ro \
    -v "${BACKUP_DIR}/volumes":/backup \
    alpine tar czf /backup/uploads_data.tar.gz -C /source . \
    && log_success "  uploads_data volume backed up" \
    || log_warn "  Failed to backup uploads_data volume"

# ============================================================
# 5. BACKUP DOCKER IMAGES
# ============================================================
log_info "Step 5/6: Backing up Docker images..."

IMAGES=(
    "mycoinflip_frontend"
    "mycoinflip_server"
    "postgres:16-alpine"
    "certbot/certbot"
)

for img in "${IMAGES[@]}"; do
    safe_name=$(echo "${img}" | tr '/:' '_')
    log_info "  → Saving image: ${img}..."
    if docker image inspect "${img}" &>/dev/null; then
        docker save "${img}" | gzip > "${BACKUP_DIR}/images/${safe_name}.tar.gz"
        log_success "  ${img} saved"
    else
        log_warn "  Image '${img}' not found, skipping"
    fi
done

# ============================================================
# 6. BACKUP NGINX & CERTBOT CONFIGS
# ============================================================
log_info "Step 6/6: Backing up Nginx & SSL certificates..."

# Nginx configs
if [[ -d "${PROJECT_DIR}/nginx" ]]; then
    cp -r "${PROJECT_DIR}/nginx" "${BACKUP_DIR}/configs/nginx"
    log_success "Nginx config backed up"
fi

if [[ -f "${PROJECT_DIR}/nginx.conf" ]]; then
    cp "${PROJECT_DIR}/nginx.conf" "${BACKUP_DIR}/configs/"
    log_success "nginx.conf backed up"
fi

# Certbot / Let's Encrypt
if [[ -d "${PROJECT_DIR}/certbot" ]]; then
    cp -r "${PROJECT_DIR}/certbot" "${BACKUP_DIR}/configs/certbot"
    log_success "Certbot/SSL certificates backed up"
fi

# ============================================================
# CREATE FINAL ARCHIVE
# ============================================================
log_info "Creating final archive..."

tar czf "${BACKUP_ROOT}/${ARCHIVE_NAME}" -C "${BACKUP_ROOT}" "backup_${TIMESTAMP}"
log_success "Archive created: ${BACKUP_ROOT}/${ARCHIVE_NAME}"

# ============================================================
# GENERATE BACKUP MANIFEST
# ============================================================
cat > "${BACKUP_DIR}/BACKUP_MANIFEST.txt" << EOF
============================================
  MyCoinFlip Full Backup Manifest
============================================
Timestamp:    ${TIMESTAMP}
Date:         $(date)
Server:       $(hostname)
Archive:      ${ARCHIVE_NAME}

Contents:
  source_code/     - Full project source (excl. node_modules, .git)
  database/        - PostgreSQL dump (.dump custom format + .sql plain)
  volumes/         - Docker volume tarballs (postgres_data, uploads_data)
  images/          - Docker image tarballs (frontend, server, postgres, certbot)
  configs/         - .env, docker-compose, nginx, certbot/SSL

Restore Instructions:
  1. Extract:   tar xzf ${ARCHIVE_NAME}
  2. Source:    cp -r source_code/* /opt/mycoinflip/
  3. Env:       cp configs/env_backup_${TIMESTAMP} /opt/mycoinflip/.env
  4. Images:    docker load < images/<image>.tar.gz
  5. Volumes:   See below
  6. Database:  docker exec -i <db_container> pg_restore -U <user> -d <db> < database/*.dump
  7. Start:     cd /opt/mycoinflip && docker compose -f docker-compose.prod.yml up -d

Volume Restore:
  docker run --rm -v mycoinflip_postgres_data:/target -v \$(pwd)/volumes:/backup alpine sh -c 'tar xzf /backup/postgres_data.tar.gz -C /target'
  docker run --rm -v mycoinflip_uploads_data:/target -v \$(pwd)/volumes:/backup alpine sh -c 'tar xzf /backup/uploads_data.tar.gz -C /target'
============================================
EOF

# Also include manifest in the archive
tar czf "${BACKUP_ROOT}/${ARCHIVE_NAME}" -C "${BACKUP_ROOT}" "backup_${TIMESTAMP}"

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "=============================================="
echo "  Backup Complete!"
echo "=============================================="
echo ""
log_success "Archive:  ${BACKUP_ROOT}/${ARCHIVE_NAME}"
log_info    "Size:     $(du -sh "${BACKUP_ROOT}/${ARCHIVE_NAME}" | cut -f1)"
log_info    "Contents:"

du -sh "${BACKUP_DIR}"/source_code 2>/dev/null | awk '{printf "             Source Code:     %s\n", $1}'
du -sh "${BACKUP_DIR}"/database    2>/dev/null | awk '{printf "             Database:         %s\n", $1}'
du -sh "${BACKUP_DIR}"/volumes     2>/dev/null | awk '{printf "             Volumes:          %s\n", $1}'
du -sh "${BACKUP_DIR}"/images      2>/dev/null | awk '{printf "             Docker Images:    %s\n", $1}'
du -sh "${BACKUP_DIR}"/configs     2>/dev/null | awk '{printf "             Configs:          %s\n", $1}'

echo ""
log_info "To download this backup, use:"
echo "       scp root@<server-ip>:${BACKUP_ROOT}/${ARCHIVE_NAME} ."
echo ""
