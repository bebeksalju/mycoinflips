#!/bin/bash

# SSL initialization script for mcfoption.com
# Two-phase approach: HTTP-only first, then SSL

set -e

COMPOSE="docker compose -f docker-compose.prod.yml"
DOMAIN="mcfoption.com"
DOMAINS=("mcfoption.com" "www.mcfoption.com")
EMAIL="mycoinflips@protonmail.com"  # Email kontak Let's Encrypt
CERTBOT_CONF="./certbot/conf"
CERTBOT_WWW="./certbot/www"
NGINX_CONF="./nginx/conf.d"

echo "============================================"
echo " MCFOPTION SSL Setup Script"
echo "============================================"
echo ""

# --- FASE 1: Setup HTTP-only untuk validasi ---
echo "### [FASE 1] Menyiapkan Nginx HTTP-only untuk validasi Let's Encrypt..."

# Matikan semua container yang sedang jalan
echo ">>> Menghentikan container yang aktif..."
$COMPOSE down 2>/dev/null || true

# Buat direktori certbot
mkdir -p "$CERTBOT_CONF"
mkdir -p "$CERTBOT_WWW"

# Backup config SSL asli, ganti dengan HTTP-only
echo ">>> Memasang konfigurasi Nginx HTTP-only sementara..."
cp "$NGINX_CONF/default.conf" "$NGINX_CONF/default.conf.bak"
cp "$NGINX_CONF/default.http-only.conf.disabled" "$NGINX_CONF/default.conf"

# Jalankan frontend + server + db
echo ">>> Menjalankan Nginx (HTTP-only mode)..."
$COMPOSE up --build -d frontend server db
echo ""

# Tunggu Nginx siap
echo ">>> Menunggu Nginx siap (5 detik)..."
sleep 5

# Tes apakah port 80 bisa diakses
echo ">>> Mengecek apakah port 80 aktif..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost/.well-known/acme-challenge/test 2>/dev/null | grep -q "404\|200"; then
    echo "    ✅ Port 80 aktif dan bisa diakses!"
else
    echo "    ⚠️  Port 80 mungkin belum siap, tapi kita lanjut coba..."
fi
echo ""

# --- FASE 2: Request sertifikat SSL ---
echo "### [FASE 2] Meminta sertifikat SSL dari Let's Encrypt..."

# Build domain args
DOMAIN_ARGS=""
for d in "${DOMAINS[@]}"; do
    DOMAIN_ARGS="$DOMAIN_ARGS -d $d"
done

$COMPOSE run --rm --entrypoint "certbot" certbot certonly \
    --webroot \
    --non-interactive \
    -w /var/www/certbot \
    $DOMAIN_ARGS \
    --email "$EMAIL" \
    --rsa-key-size 4096 \
    --agree-tos \
    --no-eff-email \
    --force-renewal

echo ""

# Cek apakah sertifikat berhasil dibuat
if [ -f "$CERTBOT_CONF/live/$DOMAIN/fullchain.pem" ]; then
    echo "============================================"
    echo " ✅ SERTIFIKAT SSL BERHASIL DIBUAT!"
    echo "============================================"
    echo ""

    # --- FASE 3: Aktifkan konfigurasi SSL penuh ---
    echo "### [FASE 3] Mengaktifkan Nginx dengan SSL penuh..."

    # Kembalikan config SSL asli
    cp "$NGINX_CONF/default.conf.bak" "$NGINX_CONF/default.conf"
    rm -f "$NGINX_CONF/default.conf.bak"

    # Restart semua service
    $COMPOSE down
    $COMPOSE up -d

    echo ""
    echo "============================================"
    echo " 🎉 DEPLOYMENT SELESAI!"
    echo " Website kamu sekarang live di:"
    echo "   https://mcfoption.com"
    echo "============================================"
else
    echo "============================================"
    echo " ❌ GAGAL mendapatkan sertifikat SSL."
    echo " Pastikan:"
    echo "   1. Domain mcfoption.com dan www.mcfoption.com mengarah ke IP VPS ini"
    echo "   2. Port 80 terbuka di firewall"
    echo "   3. Tidak ada layanan lain yang memakai port 80"
    echo "============================================"

    # Kembalikan config asli
    cp "$NGINX_CONF/default.conf.bak" "$NGINX_CONF/default.conf"
    rm -f "$NGINX_CONF/default.conf.bak"
fi
