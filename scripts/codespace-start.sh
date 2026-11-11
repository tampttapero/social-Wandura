#!/usr/bin/env bash
# Chay tu dong moi lan Codespace khoi dong.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -z "${CODESPACE_NAME:-}" ]; then
  echo "Script nay chi danh cho GitHub Codespaces. Tren Windows dung scripts/setup.ps1"; exit 1
fi

URL="https://${CODESPACE_NAME}-4007.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"

if [ ! -f .env ]; then
  cp .env.example .env
  sed -i "s|^JWT_SECRET=.*|JWT_SECRET=$(openssl rand -hex 32)|" .env
  sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$(openssl rand -hex 16)|" .env
  echo "Da tao .env voi mat khau ngau nhien."
fi

# Postiz chay noi bo o cong 4008, proxy Caddy mo ra cong 4007
sed -i "s|^APP_PORT=.*|APP_PORT=4008|" .env
sed -i "s|^MAIN_URL=.*|MAIN_URL=${URL}|" .env
sed -i "s|^FRONTEND_URL=.*|FRONTEND_URL=${URL}|" .env
sed -i "s|^NEXT_PUBLIC_BACKEND_URL=.*|NEXT_PUBLIC_BACKEND_URL=${URL}/api|" .env

# Cho Docker-in-Docker san sang
for i in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 2; done

docker compose -f docker-compose.yaml -f docker-compose.codespaces.yaml up -d

echo ""
echo "=============================================================="
echo " Social Wandura dang khoi dong (lan dau mat 3-5 phut)."
echo " Mo tool tai: ${URL}"
echo " Callback URL cho cac mang xa hoi: ${URL}/integrations/social/<ten>"
echo " Xem log: docker compose logs -f postiz"
echo "=============================================================="
