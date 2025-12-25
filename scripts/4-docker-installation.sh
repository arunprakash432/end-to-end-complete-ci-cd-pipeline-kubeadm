#!/usr/bin/env bash

set -euo pipefail

echo "=== Docker Installation Script (Ubuntu) ==="

# Ensure script is run with sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script with sudo:"
  echo "  sudo $0"
  exit 1
fi

echo "[1/7] Updating apt index..."
apt update -y

echo "[2/7] Installing prerequisites..."
apt install -y ca-certificates curl

echo "[3/7] Setting up Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo "[4/7] Adding Docker APT repository..."
UBUNTU_CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")

tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "[5/7] Updating apt index with Docker repo..."
apt update -y

echo "[6/7] Installing Docker Engine..."
apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "[7/7] Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

# Docker group setup
if ! getent group docker > /dev/null; then
  echo "Creating docker group..."
  groupadd docker
fi

echo "Adding user '$SUDO_USER' to docker group..."
usermod -aG docker "$SUDO_USER"

echo
echo "=== Docker installation completed successfully ==="
echo "Log out and log back in (or run: newgrp docker) to use Docker without sudo."
