#!/bin/bash

# Exit on error
set -e

# Remove existing .NET SDK if present
if dpkg -l | grep -q dotnet-sdk-6.0; then
  echo "Removing existing .NET SDK..."
  sudo apt remove -y dotnet-sdk-6.0 || true
fi

# Download .NET SDK 6.0
echo "Downloading .NET SDK 6.0..."
wget -O /tmp/dotnet-sdk-6.0.424-linux-x64.tar.gz https://download.visualstudio.microsoft.com/download/pr/e94bb674-1fb1-4966-b2f0-bc9055ea33fc/428b37dee8ffb641fd1e45b401b2994c/dotnet-sdk-6.0.424-linux-x64.tar.gz

# Create installation directory for .NET SDK
echo "Creating installation directory..."
sudo mkdir -p /usr/share/dotnet
sudo chmod 755 /usr/share/dotnet

# Extract .NET SDK
echo "Extracting .NET SDK..."
sudo tar -xzf /tmp/dotnet-sdk-6.0.424-linux-x64.tar.gz -C /usr/share/dotnet

# Add .NET to PATH in .bashrc
echo "Updating .bashrc..."
echo 'export DOTNET_ROOT=/usr/share/dotnet' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/share/dotnet' >> ~/.bashrc

# Update environment variables for all users
echo "Updating environment variables..."
echo 'export DOTNET_ROOT=/usr/share/dotnet' | sudo tee -a /etc/profile
echo 'export PATH=$PATH:/usr/share/dotnet' | sudo tee -a /etc/profile

# Reload .bashrc to update current shell session
source ~/.bashrc

# Verify .NET 6 installation
echo "Verifying .NET 6 installation..."

