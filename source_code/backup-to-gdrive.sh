#!/bin/bash
# ==============================================================================
#  MyCoinFlip Backup script to Google Drive (rclone)
#  Runs weekly (recommended via Cron)
# ==============================================================================

set -e

# Config
PROJECT_DIR="/opt/mycoinflip"
BACKUP_ROOT_DIR="${PROJECT_DIR}/backups"
RCLONE_REMOTE="gdrive"
RCLONE_FOLDER="mycoinflip-backups"

# Create backup root directory if not exist
mkdir -p "${BACKUP_ROOT_DIR}"

# 1. Load env variables
if [ -f "${PROJECT_DIR}/.env" ]; then
    # Load and export all variables (excluding comments)
    export $(grep -v '^#' "${PROJECT_DIR}/.env" | xargs)
else
    echo "❌ ERROR: .env file not found in ${PROJECT_DIR}."
    exit 1
fi

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${DATE}"
TEMP_BACKUP_DIR="${BACKUP_ROOT_DIR}/${BACKUP_NAME}"
ARCHIVE_PATH="${BACKUP_ROOT_DIR}/${BACKUP_NAME}.tar.gz"

echo "============================================="
echo " Starting MyCoinFlip Backup Process... "
echo " Date: $(date)"
echo "============================================="

# Create temporary folder structures
mkdir -p "${TEMP_BACKUP_DIR}/db_backup"
mkdir -p "${TEMP_BACKUP_DIR}/uploads_backup"
mkdir -p "${TEMP_BACKUP_DIR}/source_code"

# 2. Dump Database (PostgreSQL)
echo "1. Exporting Database from Docker container..."
if docker ps | grep -q mycoinflip-db-1; then
    docker exec -i mycoinflip-db-1 pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" > "${TEMP_BACKUP_DIR}/db_backup/db_dump.sql"
    echo "   -> Database backup successful."
else
    echo "   ❌ ERROR: Container mycoinflip-db-1 is not running!"
    rm -rf "${TEMP_BACKUP_DIR}"
    exit 1
fi

# 3. Backup Uploads Volume (KYC & Transfer Proof images)
echo "2. Copying uploads files..."
if docker ps | grep -q mycoinflip-server-1; then
    docker run --rm --volumes-from mycoinflip-server-1 -v "${TEMP_BACKUP_DIR}/uploads_backup":/backup_host alpine cp -rp /app/uploads/. /backup_host/
    echo "   -> Uploads directory copy successful."
else
    echo "   ❌ ERROR: Container mycoinflip-server-1 is not running!"
    rm -rf "${TEMP_BACKUP_DIR}"
    exit 1
fi

# 4. Copy Source Code & Config
echo "3. Copying source code and configuration..."
rsync -avq \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='backups' \
    --exclude='*.tar.gz' \
    "${PROJECT_DIR}/" "${TEMP_BACKUP_DIR}/source_code/"
echo "   -> Source code copy successful."

# 5. Compress into tar.gz
echo "4. Compressing backup into tar.gz..."
tar -czf "${ARCHIVE_PATH}" -C "${BACKUP_ROOT_DIR}" "${BACKUP_NAME}"
echo "   -> Backup archive created: ${ARCHIVE_PATH}"

# 6. Upload to Google Drive using Rclone
echo "5. Uploading to Google Drive..."
if rclone listremotes | grep -q "^${RCLONE_REMOTE}:"; then
    rclone copy "${ARCHIVE_PATH}" "${RCLONE_REMOTE}:${RCLONE_FOLDER}"
    echo "   -> Backup successfully uploaded to Google Drive!"
else
    echo "   ❌ ERROR: Rclone remote '${RCLONE_REMOTE}' is not configured!"
    echo "   Please run 'rclone config' to set up a remote named '${RCLONE_REMOTE}'."
    rm -rf "${TEMP_BACKUP_DIR}"
    exit 1
fi

# 7. Clean up temporary files
echo "6. Cleaning up temporary folders..."
rm -rf "${TEMP_BACKUP_DIR}"

# 8. Clean up local backups older than 14 days to save VPS disk space
echo "7. Cleaning up local backups older than 14 days..."
find "${BACKUP_ROOT_DIR}" -name "backup_*.tar.gz" -mtime +14 -delete

echo "============================================="
echo " ✅ BACKUP COMPLETED SUCCESSFUL!"
echo "============================================="
