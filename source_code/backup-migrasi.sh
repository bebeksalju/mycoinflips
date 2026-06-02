#!/bin/bash
set -e

# Config
BACKUP_DIR="mycoinflip-backup-temp"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="mycoinflip_vps_migrasi_${DATE}.tar.gz"

echo "==================================================="
echo " Memulai Proses Backup MyCoinFlip (dengan rsync) "
echo "==================================================="

mkdir -p $BACKUP_DIR
mkdir -p $BACKUP_DIR/db_backup
mkdir -p $BACKUP_DIR/uploads_backup
mkdir -p $BACKUP_DIR/source_code

echo "1. Mengambil Database Backup (PostgreSQL)..."
# Menggunakan docker exec langsung ke nama container (lebih stabil)
if docker ps | grep -q mycoinflip-db-1; then
    source .env
    docker exec -i mycoinflip-db-1 pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > $BACKUP_DIR/db_backup/db_dump.sql
    echo "   -> Database berhasil di-backup"
else
    echo "   ❌ ERROR: Container mycoinflip-db-1 tidak berjalan."
    rm -rf $BACKUP_DIR
    exit 1
fi

echo "2. Mengekstrak volume uploads (Gambar KYC/Bukti Transfer)..."
# Copy isi map uploads_data menggunakan volumes-from container server
docker run --rm --volumes-from mycoinflip-server-1 -v $(pwd)/$BACKUP_DIR/uploads_backup:/backup_host alpine cp -r /app/uploads/ /backup_host/ 2>/dev/null || true
echo "   -> Uploads (file gambar) berhasil di-backup"

echo "3. Menyalin Source Code, Konfigurasi & Sertifikat SSL (rsync)..."
# Menggunakan rsync sesuai permintaan untuk ignore node_modules dsb.
rsync -avq \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='mycoinflip-backup-temp' \
    --exclude='*.tar.gz' \
    ./ $BACKUP_DIR/source_code/
echo "   -> Source Code, file .env, dan SSL berhasil disalin"

echo "4. Mengompres semuanya menjadi 1 file arsip final..."
tar -czf $ARCHIVE_NAME $BACKUP_DIR/
echo "   -> Arsip final $ARCHIVE_NAME berhasil dibuat!"

echo "5. Membersihkan folder sementara..."
rm -rf $BACKUP_DIR

echo ""
echo "========================================================="
echo " ✅ BACKUP SELESAI!"
echo "========================================================="
echo " File siap di-download (gunakan SFTP, FileZilla, dll):"
echo " 📁 $(pwd)/$ARCHIVE_NAME"
echo ""
echo " --- CARA RESTORE DI VPS BARU ---"
echo " 1. Upload dan ekstrak:"
echo "      tar -xzf $ARCHIVE_NAME"
echo " 2. Masuk ke folder source_code:"
echo "      cd mycoinflip-backup-temp/source_code"
echo " 3. Jalankan Docker di VPS baru:"
echo "      docker compose -f docker-compose.prod.yml up --build -d"
echo " 4. Restore database (tunggu server menyala dulu sebentar):"
echo "      source .env"
echo "      docker exec -i mycoinflip-db-1 psql -U \$POSTGRES_USER \$POSTGRES_DB < ../db_backup/db_dump.sql"
echo " 5. Kembalikan folder uploads:"
echo "      docker run --rm --volumes-from mycoinflip-server-1 -v \$(pwd)/../uploads_backup/uploads:/backup_host alpine cp -r /backup_host/* /app/uploads/"
echo " 6. Restart server backend agar data baru terbaca:"
echo "      docker restart mycoinflip-server-1"
echo "========================================================="
