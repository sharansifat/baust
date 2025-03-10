#!/bin/bash

# Install dependencies
pnpm install

# Build the application
pnpm run build

# Start the application using PM2
pm2 start ecosystem.config.js

# Save PM2 process list
pm2 save

# Setup Nginx configuration
sudo tee /etc/nginx/sites-available/baust.xyz > /dev/null << EOL
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

# Enable the site
sudo ln -sf /etc/nginx/sites-available/baust.xyz /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Setup SSL certificate
sudo certbot --nginx -d baust.xyz -d www.baust.xyz --non-interactive --agree-tos --email contact.to.sifat@gmail.com
