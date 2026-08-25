#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root (e.g., sudo ./setup-fail2ban.sh)"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "=== 1. Updating Package Indexes & Installing Fail2ban ==="
apt-get update -q
apt-get install -y -q fail2ban iptables

echo "=== 2. Writing Fail2ban SSH Local Jail Configuration ==="
cat <<'EOF' > /etc/fail2ban/jail.local
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
banaction = iptables-multiport

[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
EOF

echo "=== 3. Enabling and Restarting Fail2ban ==="
systemctl enable --now fail2ban
systemctl restart fail2ban

# Wait up to 5 seconds for the socket file to exist
echo "Waiting for fail2ban socket..."
count=0
while [ ! -S /var/run/fail2ban/fail2ban.sock ] && [ $count -lt 5 ]; do
    sleep 1
    ((count++))
done

echo "=== 4. Verifying SSH Jail Status ==="
fail2ban-client status sshd

echo "=== Fail2ban installation and setup complete! ==="