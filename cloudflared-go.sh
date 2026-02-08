#!/bin/bash

DOMAIN="jon.biz.id"
TUNNEL_NAME="jonsnow-tunnel"

echo "=== INSTALL CLOUDFLARED ==="
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
apt update
apt install -y cloudflared

echo "=== LOGIN CLOUDFLARE ==="
cloudflared tunnel login

echo "=== CREATE TUNNEL ==="
cloudflared tunnel create $TUNNEL_NAME

TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')

echo "Tunnel ID: $TUNNEL_ID"

echo "=== CONFIG TUNNEL ==="
mkdir -p /etc/cloudflared

cat > /etc/cloudflared/config.yml <<EOF
tunnel: $TUNNEL_ID
credentials-file: /root/.cloudflare/$TUNNEL_ID.json

ingress:
  - hostname: $DOMAIN
    service: http://localhost:80
  - service: http_status:404
EOF

echo "=== DNS ROUTE ==="
cloudflared tunnel route dns $TUNNEL_NAME $DOMAIN

echo "=== INSTALL SERVICE ==="
cloudflared service install

echo "=== START SERVICE ==="
systemctl enable cloudflared
systemctl restart cloudflared

echo "======================================"
echo " WEBSITE ONLINE: https://$DOMAIN "
echo "======================================"
