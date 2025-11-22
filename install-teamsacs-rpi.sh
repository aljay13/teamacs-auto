#!/bin/bash
set -e

echo "=================================="
echo "   Installing TeamsACS on RPi4"
echo "=================================="

# 1️⃣ Add user to Docker group
echo "[1/7] Adding user $USER to docker group..."
sudo usermod -aG docker $USER || true
newgrp docker || true

# 2️⃣ Update system
echo "[2/7] Updating system..."
sudo apt update -y
sudo apt upgrade -y

# 3️⃣ Install Docker if missing
echo "[3/7] Installing Docker..."
if ! command -v docker >/dev/null 2>&1; then
    curl -fsSL https://get.docker.com | sh
else
    echo "Docker already installed"
fi

# 4️⃣ Install Docker Compose v2 plugin
echo "[4/7] Installing Docker Compose v2 plugin..."
sudo mkdir -p /usr/libexec/docker/cli-plugins
sudo curl -SL "https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-aarch64" -o /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Verify Compose
docker compose version

# 5️⃣ Create TeamsACS folder if missing
echo "[5/7] Setting up TeamsACS directory..."
mkdir -p ~/teamsacs
cd ~/teamsacs

# 6️⃣ Pull install repo if missing
if [ ! -f install-teamsacs.sh ]; then
    echo "[6/7] Downloading TeamsACS install script..."
    curl -sSL https://raw.githubusercontent.com/aljay13/teamacs-auto/main/install-teamsacs.sh -o install-teamsacs.sh
    chmod +x install-teamsacs.sh
fi

# 7️⃣ Launch TeamsACS containers
echo "[7/7] Launching TeamsACS..."
bash install-teamsacs.sh

echo ""
echo "✅ Installation complete!"
echo "Use 'docker compose ps' to check running containers"
echo "Your TeamsACS web dashboard should now be available on your Pi's IP."
