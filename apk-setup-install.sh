#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root (e.g., sudo ./apt-install.sh)"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "=== 1. Updating APT Package Indexes ==="
apt-get update -q

echo "=== 2. Installing Core System Utilities ==="
apt-get install -y -q \
  curl \
  git \
  htop \
  iotop \
  net-tools \
  ca-certificates \
  gnupg \
  lsb-release

echo "=== 3. Setting Up Official Docker Repository ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb-release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== 4. Installing Docker Engine & Docker Compose Plugin ==="
apt-get update -q
apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== 5. Enabling & Starting Docker Service ==="
systemctl enable --now docker

# Add non-root user 'admin' or SUDO_USER to the docker group if present
TARGET_USER="${SUDO_USER:-admin}"
if id "$TARGET_USER" &>/dev/null; then
  usermod -aG docker "$TARGET_USER"
  echo "Added user '$TARGET_USER' to the docker group."
fi

echo "=== General installation and Docker setup complete! ==="