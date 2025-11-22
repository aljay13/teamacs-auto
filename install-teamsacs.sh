#!/bin/bash
set -e

echo "=================================="
echo "   Installing TeamsACS on RPi4    "
echo "=================================="

echo "[1/10] Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "[2/10] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo systemctl enable docker
sudo systemctl start docker

echo "[3/10] Installing Docker Compose..."
sudo apt install -y docker-compose-plugin

echo "[4/10] Creating TeamsACS directory..."
mkdir -p ~/teamsacs
cd ~/teamsacs

echo "[5/10] Creating data folders..."
mkdir -p data/mongodb
mkdir -p data/redis
mkdir -p data/teamsacs

echo "[6/10] Creating docker-compose.yml..."
cat << 'EOF' > docker-compose.yml
version: "3.9"

services:
  mongodb:
    image: mongo:6.0
    container_name: teamsacs-mongo
    restart: unless-stopped
    volumes:
      - ./data/mongodb:/data/db
    ports:
      - "27017:27017"

  redis:
    image: redis:7
    container_name: teamsacs-redis
    restart: unless-stopped
    volumes:
      - ./data/redis:/data
    ports:
      - "6379:6379"

  teamsacs:
    image: ca17/teamsacs:latest
    container_name: teamsacs
    depends_on:
      - mongodb
      - redis
    restart: unless-stopped
    ports:
      - "58080:58080"
      - "58081:58081"
    environment:
      - MONGO_URL=mongodb://mongodb:27017
      - REDIS_HOST=redis
    volumes:
      - ./data/teamsacs:/app/data

EOF

echo "[7/10] Pulling images..."
sudo docker compose pull

echo "[8/10] Starting services..."
sudo docker compose up -d

echo "[9/10] Checking status..."
sudo docker compose ps

echo "[10/10] Installation finished!"
echo ""
echo "============================================="
echo "  TeamsACS Installed Successfully!"
echo ""
echo "  Web UI: http://<your-rpi-ip>:58080"
echo "  Default Login: admin / admin"
echo ""
echo "  MongoDB:   localhost:27017"
echo "  Redis:     localhost:6379"
echo ""
echo "============================================="
