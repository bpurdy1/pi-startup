#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root (e.g., sudo ./uninstall-log2ram.sh)"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "=== 1. Stopping & Disabling log2ram Service ==="
# Stopping the service forces log2ram to write its current RAM contents back to disk
systemctl stop log2ram || true
systemctl disable log2ram || true

echo "=== 2. Purging log2ram Package ==="
apt-get purge -y -q log2ram

echo "=== 3. Cleaning Up Repository and Configuration Files ==="
rm -f /etc/log2ram.conf
rm -f /etc/apt/sources.list.d/log2ram.list
rm -f /usr/share/keyrings/log2ram-archive-keyring.gpg

echo "=== 4. Removing Orphan Dependencies ==="
apt-get autoremove -y -q --purge

echo "=== log2ram uninstallation complete! ==="
echo "IMPORTANT: You must reboot your Pi to fully unmount the RAM disk and restore /var/log to your physical drive."
echo "Run: sudo reboot"