#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set variables
APP_NAME="baust"
DOCKER_IMAGE="${APP_NAME}:latest"
DOCKER_CONTAINER_NAME="${APP_NAME}-container"
PORT=5173

# Print a message with a color
print_message() {
    echo -e "${2}$1${NC}"
}

# Check if Docker is installed
print_message "Checking Docker installation..." "$YELLOW"
if ! command -v docker &> /dev/null; then
    print_message "Docker is not installed. Installing Docker..." "$YELLOW"
    
    # Update package lists
    sudo apt update
    
    # Install prerequisites
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package database with Docker packages
    sudo apt update
    
    # Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # Install Docker Compose
    sudo apt install -y docker-compose-plugin
    
    # Add your user to the docker group to run Docker without sudo
    sudo usermod -aG docker $USER
    
    print_message "Docker installed successfully!" "$GREEN"
    print_message "You may need to log out and log back in for the docker group changes to take effect." "$YELLOW"
else
    print_message "Docker is already installed." "$GREEN"
fi

# Ensure .env file exists
if [ ! -f .env ]; then
    if [ -f .env.production ]; then
        print_message "Creating .env from .env.production..." "$YELLOW"
        cp .env.production .env
    else
        print_message "Warning: No .env or .env.production file found. Creating empty .env file." "$YELLOW"
        touch .env
    fi
fi

# Build Docker image
print_message "Building Docker image..." "$YELLOW"
docker build -t ${DOCKER_IMAGE} --target bolt-ai-production .
print_message "Docker image built successfully!" "$GREEN"

# Stop and remove existing container if it exists
if docker ps -a | grep -q ${DOCKER_CONTAINER_NAME}; then
    print_message "Stopping and removing existing container..." "$YELLOW"
    docker stop ${DOCKER_CONTAINER_NAME} || true
    docker rm ${DOCKER_CONTAINER_NAME} || true
fi

# Run the Docker container
print_message "Starting Docker container..." "$YELLOW"
docker run -d --name ${DOCKER_CONTAINER_NAME} \
    -p ${PORT}:${PORT} \
    --restart unless-stopped \
    --env-file .env \
    ${DOCKER_IMAGE}
print_message "Docker container started successfully!" "$GREEN"

# Configure Nginx if it's installed
if command -v nginx &> /dev/null; then
    print_message "Configuring Nginx as a reverse proxy..." "$YELLOW"
    
    # Create Nginx configuration
    NGINX_CONF="/etc/nginx/sites-available/${APP_NAME}"
    sudo bash -c "cat > ${NGINX_CONF} << EOL
server {
    listen 80;
    listen [::]:80;
    server_name \$hostname;

    location / {
        proxy_pass http://localhost:${PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \\\$host;
        proxy_cache_bypass \\\$http_upgrade;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \\\$scheme;
    }
}
EOL"
    
    # Enable the site
    sudo ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl restart nginx
    
    print_message "Nginx configured successfully!" "$GREEN"
fi

# Print deployment information
print_message "\n=== Deployment Summary ===" "$GREEN"
print_message "Application: ${APP_NAME}" "$GREEN"
print_message "Container: ${DOCKER_CONTAINER_NAME}" "$GREEN"
print_message "Port: ${PORT}" "$GREEN"
print_message "Access the application at: http://localhost:${PORT}" "$GREEN"
if command -v nginx &> /dev/null; then
    print_message "Nginx configured: Yes" "$GREEN"
    print_message "Access through Nginx: http://$(hostname)" "$GREEN"
fi

print_message "\nTo view container logs:" "$YELLOW"
print_message "docker logs ${DOCKER_CONTAINER_NAME}" "$NC"

print_message "\nTo restart the container:" "$YELLOW"
print_message "docker restart ${DOCKER_CONTAINER_NAME}" "$NC"

print_message "\nDeployment completed!" "$GREEN"
