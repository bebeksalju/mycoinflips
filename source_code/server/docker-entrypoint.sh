#!/bin/sh
set -e

# Ensure upload directories exist
mkdir -p uploads/kyc uploads/proofs

echo "Syncing database schema..."
npx prisma db push

echo "Starting server..."
exec node src/server.js
