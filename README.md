# BAUST

## Overview
BAUST is an AI agent application built with Remix and React, offering a modern web interface for AI interactions.

## Deployment Guide for Ubuntu with Docker

### Prerequisites
- Ubuntu 20.04 LTS or newer
- Git
- Docker and Docker Compose (automatically installed by the deployment script if not present)

### Quick Deployment

1. Clone the repository:
```bash
git clone https://github.com/mdsharansifat/baust.git
cd baust
```

2. Run the deployment script:
```bash
chmod +x deploy-ubuntu-docker.sh
./deploy-ubuntu-docker.sh
```

The script will:
- Install Docker if not already installed
- Create necessary environment files
- Build the Docker image
- Run the container
- Configure Nginx as a reverse proxy (if Nginx is installed)

### Manual Deployment Steps

If you prefer to deploy manually:

1. Install Docker:
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
```

2. Deploy the application:
```bash
# Copy environment file
cp .env.production .env

# Build Docker image
docker build -t baust:latest --target bolt-ai-production .

# Run Docker container
docker run -d --name baust-container -p 5173:5173 --restart unless-stopped --env-file .env baust:latest
```

### Nginx Configuration (Optional)

To set up Nginx as a reverse proxy:

1. Install Nginx:
```bash
sudo apt install -y nginx
```

2. Create Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/baust
```

3. Add this configuration:
```
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

4. Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/baust /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### SSL Certificate (Optional)

To add HTTPS with Let's Encrypt:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Maintenance

- View container logs: `docker logs baust-container`
- Restart the container: `docker restart baust-container`
- Update the application:
```bash
git pull
docker build -t baust:latest --target bolt-ai-production .
docker stop baust-container
docker rm baust-container
docker run -d --name baust-container -p 5173:5173 --restart unless-stopped --env-file .env baust:latest
```

## Development

To run the app in development mode:

```bash
# Build development image
docker build -t baust:development --target bolt-ai-development .

# Run development container
docker run -it -p 5173:5173 -v $(pwd):/app --env-file .env baust:development
```

## License

MIT
