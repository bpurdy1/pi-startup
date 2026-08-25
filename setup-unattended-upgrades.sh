#!/usr/bin/env bash
set -e

echo "=== 1. Installing Unattended-Upgrades ==="
sudo apt update && sudo apt install -y unattended-upgrades

echo "=== 2. Enabling Automatic Background Updates ==="
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::AutocleanInterval "7";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades

echo "=== 3. Overriding DPkg Options to Prevent Prompts ==="
cat <<'EOF' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-custom
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Automatic-Reboot "false";
DPkg::Options {
   "--force-confdef";
   "--force-confold";
};
EOF

echo "=== 4. Restarting Service ==="
sudo systemctl restart unattended-upgrades

echo "=== Host auto-update configuration complete! ==="
