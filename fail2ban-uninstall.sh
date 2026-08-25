#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root (e.g., sudo ./uninstall-fail2ban.sh)"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "=== 1. Stopping & Disabling Fail2ban Service ==="
systemctl stop fail2ban || true
systemctl disable fail2ban || true

echo "=== 2. Purging Fail2ban Package ==="
apt-get purge -y -q fail2ban

echo "=== 3. Cleaning Up Configuration & Runtime Files ==="
rm -f /etc/fail2ban/jail.local
rm -rf /etc/fail2ban/jail.d/
rm -rf /var/run/fail2ban /var/lib/fail2ban /var/log/fail2ban*

echo "=== 4. Removing Orphan Dependencies & Cleaning APT Cache ==="
apt-get autoremove -y -q --purge
apt-get clean -q

echo "=== Fail2ban uninstallation complete! ==="