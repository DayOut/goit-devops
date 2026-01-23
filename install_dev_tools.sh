#!/bin/bash

set -e

echo "Updating system..."
sudo apt update -y

# Docker
if ! command -v docker &> /dev/null; then
  echo "🐳 Installing Docker..."
  sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
else
  echo "Docker already installed"
fi

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo "Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "Docker Compose already installed"
fi

# Python 3.9+
if ! command -v python3 &> /dev/null || [[ $(python3 -c 'import sys; print(sys.version_info >= (3,9))') != "True" ]]; then
  echo "Installing Python 3.9+..."
  sudo apt install -y python3 python3-pip python3-venv
else
  echo "Python 3.9+ already installed"
fi

# Django
if ! python3 -m django &> /dev/null; then
  echo "Installing Django..."
  python3 -m pip install --upgrade pip
  python3 -m pip install django
else
  echo "Django already installed"
fi

echo "All development tools are installed!"
