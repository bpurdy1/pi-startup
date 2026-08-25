#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root (e.g., sudo ./log2ram-install.sh)"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "=== 1. Ensuring Prerequisites Are Installed ==="
apt-get update -q
apt-get install -y -q curl gnupg rsync

echo "=== 2. Adding Official Azlux log2ram Repository & Keyring ==="
# Download official GPG key directly from Azlux
curl -fsSL https://azlux.fr/repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/log2ram-archive-keyring.gpg --yes

# Dynamically extract current OS codename (e.g., bookworm, trixie)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

# Fallback to bookworm if codename is blank
if [ -z "$CODENAME" ]; then
  CODENAME="bookworm"
fi

echo "deb [signed-by=/usr/share/keyrings/log2ram-archive-keyring.gpg] http://packages.azlux.fr/debian/ ${CODENAME} main" | tee /etc/apt/sources.list.d/log2ram.list > /dev/null

echo "=== 3. Installing log2ram Package ==="
apt-get update -q
apt-get install -y -q log2ram

echo "=== 4. Configuring RAM Disk Allocation ==="
if [ -f /etc/log2ram.conf ]; then
  sed -i 's/^SIZE=.*/SIZE=128M/' /etc/log2ram.conf
  sed -i 's/^USE_RSYNC=.*/USE_RSYNC=true/' /etc/log2ram.conf
fi

echo "=== 5. Enabling Service ==="
systemctl enable log2ram

echo "=== Log2ram installation and setup complete! (Reboot required to activate RAM disk) ==="