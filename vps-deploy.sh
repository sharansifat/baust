#!/bin/bash

# Set variables
VPS_IP="178.16.140.235"
VPS_USER="root"
APP_DIR="/var/www/baust.xyz"

# Step 1: Create necessary directories on VPS and clean up old installation
ssh ${VPS_USER}@${VPS_IP} "
    echo 'Stopping any running PM2 processes...'
    pm2 stop all || true
    pm2 delete all || true
    pm2 save --force || true
    
    echo 'Cleaning up old installation...'
    mkdir -p ${APP_DIR}
    rm -rf ${APP_DIR}/*
"

# Step 2: Copy the built app and necessary files to the VPS
echo "Copying files to VPS..."
rsync -avz --exclude 'node_modules' --exclude '.git' \
  ~/Desktop/baust.xyz/ ${VPS_USER}@${VPS_IP}:${APP_DIR}/

# Step 3: Install dependencies and configure the app on the VPS
ssh ${VPS_USER}@${VPS_IP} "
    cd ${APP_DIR}
    
    echo 'Installing dependencies...'
    pnpm install
    
    echo 'Setting up environment...'
    cp .env.production .env || echo 'No .env.production file found'
    
    echo 'Starting the application with PM2...'
    pm2 start ecosystem.config.js
    pm2 save
    
    echo 'Setting up Nginx configuration...'
    cat > /etc/nginx/sites-available/baust.xyz << 'EOL'
server {
    listen 80;
    server_name baust.xyz www.baust.xyz;

    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL
    
    ln -sf /etc/nginx/sites-available/baust.xyz /etc/nginx/sites-enabled/
    
    echo 'Testing Nginx configuration...'
    nginx -t
    
    echo 'Restarting Nginx...'
    systemctl restart nginx
    
    echo 'Checking if SSL certificate is needed...'
    if [ ! -f /etc/letsencrypt/live/baust.xyz/fullchain.pem ]; then
        echo 'Setting up SSL certificate...'
        certbot --nginx -d baust.xyz -d www.baust.xyz --non-interactive --agree-tos --email contact.to.sifat@gmail.com
    else
        echo 'SSL certificate already exists'
    fi
    
    echo 'Deployment completed successfully!'
"

echo "Deployment process completed!"
