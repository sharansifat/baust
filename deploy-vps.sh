#!/bin/bash

# Set variables
VPS_IP="178.16.140.235"
VPS_USER="root"
VPS_PASSWORD="MyFirstApp@12"
APP_DIR="/var/www/baust.xyz"

# Function to execute remote commands
remote_exec() {
    sshpass -p "$VPS_PASSWORD" ssh -o StrictHostKeyChecking=no ${VPS_USER}@${VPS_IP} "$1"
}

# Transfer files to VPS
echo "Transferring files to VPS..."
sshpass -p "$VPS_PASSWORD" rsync -avz --exclude 'node_modules' --exclude '.git' \
  --exclude 'build' ./ ${VPS_USER}@${VPS_IP}:${APP_DIR}/

# Install dependencies and build the app on the VPS
echo "Installing dependencies and building app on VPS..."
remote_exec "cd ${APP_DIR} && pnpm install"
remote_exec "cd ${APP_DIR} && pnpm run build"

# Configure and start the application
echo "Configuring and starting the application..."
remote_exec "cd ${APP_DIR} && pm2 start ecosystem.config.js"
remote_exec "pm2 save"

# Configure Nginx
echo "Configuring Nginx..."
remote_exec "cat > /etc/nginx/sites-available/baust.xyz << 'EOL'
server {
    listen 80;
    listen [::]:80;
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
EOL"

# Enable the site
echo "Enabling the site..."
remote_exec "ln -sf /etc/nginx/sites-available/baust.xyz /etc/nginx/sites-enabled/"
remote_exec "nginx -t && systemctl restart nginx"

# Setup SSL
echo "Setting up SSL..."
remote_exec "certbot --nginx -d baust.xyz -d www.baust.xyz --non-interactive --agree-tos --email contact.to.sifat@gmail.com || echo 'SSL setup failed, please check domain configuration'"

echo "Deployment completed!"
