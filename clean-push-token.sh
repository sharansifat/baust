#!/bin/bash

# Get the GitHub token from gh CLI
TOKEN=$(gh auth token)

if [ -z "$TOKEN" ]; then
  echo "Error: Could not get GitHub token. Please make sure you're logged in with gh CLI."
  exit 1
fi

# Create a clean directory
rm -rf /tmp/baust-clean
mkdir -p /tmp/baust-clean

# Copy all files (excluding .git directory and sensitive files)
rsync -av --exclude '.git/' --exclude '.env.production' /Users/mdsharansifat/Desktop/baust.xyz/ /tmp/baust-clean/

# Create a safe version of .env.production
cat > /tmp/baust-clean/.env.production << 'EOL'
# App Configuration
NODE_ENV=production
PORT=5173

# Domain Configuration
DOMAIN=baust.xyz
SERVER_IP=178.16.140.235

# GitHub Configuration
# Add your GitHub token here if needed (but don't commit it!)
# GITHUB_TOKEN=your_token_here

# Server Configuration
HOST=0.0.0.0

# Time Zone
TZ=Asia/Dhaka
EOL

# Initialize git in the clean directory
cd /tmp/baust-clean
git init
git checkout -b main
git add .
git commit -m "Initial commit for Ubuntu with Docker deployment"

# Set up the remote with token embedded in URL
git remote add origin "https://${TOKEN}@github.com/sharansifat/baust.git"

# Push to GitHub using the token
git push -u origin main --force

echo "Success! The repository has been pushed to GitHub with a clean history."
