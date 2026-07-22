#!/bin/bash
# ==============================================================================
#  MyCoinFlip Daily Backup to GitHub Script
# ==============================================================================

set -e

# Config
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_PARENT_DIR="${PROJECT_DIR}/backups"
BACKUP_REPO_DIR="${BACKUP_PARENT_DIR}/github-backup-repo"

# 1. Load env variables for Database
if [ -f "${PROJECT_DIR}/.env" ]; then
    set -a
    source "${PROJECT_DIR}/.env"
    set +a
else
    echo "❌ ERROR: .env file not found in ${PROJECT_DIR}."
    exit 1
fi

# Load GitHub config from environment or script variables
GITHUB_USER="${GITHUB_USER:-YOUR_GITHUB_USERNAME}"
GITHUB_TOKEN="${GITHUB_TOKEN:-YOUR_GITHUB_PERSONAL_ACCESS_TOKEN}"
GITHUB_REPO="${GITHUB_REPO:-mycoinflip-backup}"

if [ "${GITHUB_TOKEN}" == "YOUR_GITHUB_PERSONAL_ACCESS_TOKEN" ] || [ -z "${GITHUB_TOKEN}" ]; then
    echo "❌ ERROR: GITHUB_TOKEN has not been set!"
    exit 1
fi

echo "============================================="
echo " Starting MyCoinFlip Backup to GitHub... "
echo " Date: $(date)"
echo "============================================="

# Create backups parent folder if it doesn't exist
mkdir -p "${BACKUP_PARENT_DIR}"

# Clone the repository if it's not cloned yet
if [ ! -d "${BACKUP_REPO_DIR}/.git" ]; then
    echo "Cloning backup repository..."
    rm -rf "${BACKUP_REPO_DIR}"
    git clone "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git" "${BACKUP_REPO_DIR}"
fi

# Go to backup repo folder
cd "${BACKUP_REPO_DIR}"

# Ensure we are on main/master branch and synced
git pull origin main || git pull origin master || true

# Create directory structure in the repo
mkdir -p db_backup
mkdir -p uploads_backup
mkdir -p source_code

# 2. Dump Database (PostgreSQL)
echo "1. Exporting Database from Docker container..."
DB_CONTAINER=$(docker ps --format '{{.Names}}' | grep source_code-db | head -n 1)
if [ -n "$DB_CONTAINER" ]; then
    docker exec -i "$DB_CONTAINER" pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" > "db_backup/db_dump.sql"
    echo "   -> Database backup successful."
else
    echo "   ❌ ERROR: Database container is not running!"
    exit 1
fi

# 3. Backup Uploads Volume (KYC & Transfer Proof images)
echo "2. Copying uploads files..."
SERVER_CONTAINER=$(docker ps --format '{{.Names}}' | grep source_code-server | head -n 1)
if [ -n "$SERVER_CONTAINER" ]; then
    docker run --rm --volumes-from "$SERVER_CONTAINER" -v "$(pwd)/uploads_backup":/backup_host alpine cp -rp /app/uploads/. /backup_host/
    echo "   -> Uploads directory copy successful."
else
    echo "   ❌ ERROR: Server container is not running!"
    exit 1
fi

# 4. Copy Source Code & Config
echo "3. Copying source code and configuration..."
# Sync files to source_code/ directory
rsync -avq --delete \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='backups' \
    --exclude='*.tar.gz' \
    "${PROJECT_DIR}/" "source_code/"
echo "   -> Source code copy successful."

# 5. Git Commit and Push
echo "4. Pushing backup to GitHub..."
git config user.name "VPS Backup Agent"
git config user.email "backup@major-tour.com"

# Check if there are changes before committing
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "Automated backup: $(date +'%Y-%m-%d %H:%M:%S')"
    # Push to main or master
    git push origin main || git push origin master
    echo "   -> Backup successfully pushed to GitHub!"
else
    echo "   -> No changes detected. Backup is up to date."
fi

echo "============================================="
echo " ✅ BACKUP COMPLETED SUCCESSFUL!"
echo "============================================="
