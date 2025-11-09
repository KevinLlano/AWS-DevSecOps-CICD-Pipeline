#!/bin/bash
# Minimal install script for monitoring stack only
# This is much faster and more reliable than the full Jenkins setup

# Update system
sudo apt update -y

# Install Docker
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
sudo systemctl start docker
sudo systemctl enable docker

# Fix Docker permissions
sudo chmod 666 /var/run/docker.sock

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
echo "Docker version:" >> /home/ubuntu/install-log.txt
docker --version >> /home/ubuntu/install-log.txt
echo "Docker Compose version:" >> /home/ubuntu/install-log.txt
docker-compose --version >> /home/ubuntu/install-log.txt
echo "Installation completed at $(date)" >> /home/ubuntu/install-log.txt

# Ensure ubuntu user can use docker
sudo usermod -aG docker ubuntu
newgrp docker
