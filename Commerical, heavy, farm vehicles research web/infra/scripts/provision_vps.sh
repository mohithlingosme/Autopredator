#!/bin/bash
set -e

echo "🚀 Provisioning VPS for AutoPredator FleetCommand..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com | sh
usermod -aG docker deploy

# Install Docker Compose
echo "📋 Installing Docker Compose..."
apt install -y docker-compose-plugin

# Create deploy user if not exists
if ! id -u deploy > /dev/null 2>&1; then
    echo "👤 Creating deploy user..."
    adduser --disabled-password --gecos "" deploy
    usermod -aG sudo deploy
    mkdir -p /home/deploy/.ssh
    chmod 700 /home/deploy/.ssh
    # Note: Add SSH key manually or via automation
fi

# Create directories
echo "📁 Creating application directories..."
mkdir -p /opt/fleetcommand/{configs,logs,data,backups}
chown -R deploy:deploy /opt/fleetcommand

# Configure firewall
echo "🔥 Configuring firewall..."
ufw --force enable
ufw allow 22/tcp  # SSH
ufw allow 80/tcp  # HTTP
ufw allow 443/tcp # HTTPS

# Install monitoring tools
echo "📊 Installing monitoring tools..."
apt install -y htop iotop ncdu

# Enable NTP
echo "🕐 Enabling NTP..."
apt install -y ntp
systemctl enable ntp

echo "✅ VPS provisioning complete!"
echo "📝 Next steps:"
echo "1. Add your SSH public key to /home/deploy/.ssh/authorized_keys"
echo "2. Copy infra/ to /opt/fleetcommand/configs/"
echo "3. Set up .env file from .env.example"
echo "4. Run deploy script"
