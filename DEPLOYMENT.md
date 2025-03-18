# BAUST - Deployment Documentation

This document outlines the complete deployment process for the BAUST application.

## Project Overview

BAUST is an AI agent application optimized for Ubuntu with Docker deployment. The application is built with:

- Node.js (v20+)
- React
- Remix
- Docker for containerization
- Nginx as a reverse proxy (optional)


## Repository Structure

The repository contains all necessary files for deployment:

- `Dockerfile` - Multi-stage build for development and production environments
- `docker-compose.yaml` - Configuration for Docker Compose deployment
- `deploy-ubuntu-docker.sh` - Script for automated deployment on Ubuntu with Docker
- `deploy-vps.sh` - Script for VPS deployment
- Various deployment and push scripts


## Deployment Methods

### Method 1: Using Docker Compose (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/sharansifat/baust.git
   cd baust
   ```

2. Create an `.env.local` file with the necessary API keys:
   ```
   GROQ_API_KEY=your_api_key_here
   OPENAI_API_KEY=your_api_key_here
   ANTHROPIC_API_KEY=your_api_key_here
   # Add other API keys as needed
   ```

3. Start with Docker Compose:
   ```bash
   # For development
   docker-compose up app-dev
   
   # For production
   docker-compose up app-prod
   ```


### Method 2: Using the Deployment Script

1. Clone the repository:
   ```bash
   git clone https://github.com/sharansifat/baust.git
   cd baust
   ```

2. Make the deployment script executable:
   ```bash
   chmod +x deploy-ubuntu-docker.sh
   ```

3. Run the deployment script:
   ```bash
   ./deploy-ubuntu-docker.sh
   ```

   This script will:
   - Install Docker if not present
   - Create an `.env` file if it doesn't exist
   - Build a Docker image
   - Run the container
   - Configure Nginx if installed


## Important Configuration Files

### Docker Compose Configuration

The `docker-compose.yaml` file defines three services:
- `app-prod`: Production build
- `app-dev`: Development build with hot reloading
- `app-prebuild`: Using a prebuilt image

Each service exposes port 5173 and uses environment variables from `.env.local`.

### Dockerfile

The Dockerfile uses a multi-stage build:
- `base`: Common base with dependencies
- `bolt-ai-production`: Optimized for production
- `bolt-ai-development`: Configured for development with hot reloading


### Environment Variables

Required environment variables:
- `GROQ_API_KEY`: For Groq AI API
- `OPENAI_API_KEY`: For OpenAI API
- `ANTHROPIC_API_KEY`: For Anthropic API
- `GOOGLE_GENERATIVE_AI_API_KEY`: For Google AI API
- Other AI provider keys as needed

## Networking

The application runs on port 5173 by default. If using Nginx, it will proxy requests to this port.


## Troubleshooting

- If Docker fails to start, check if the port 5173 is already in use
- For permission issues, ensure you're running Docker with appropriate privileges
- Check Docker logs for debugging: `docker logs baust-container`

## Backup and Restore

To back up the application:
1. Create a tarball of the project directory:
   ```bash
   tar -czvf baust-backup.tar.gz /path/to/baust
   ```

2. To restore:
   ```bash
   tar -xzvf baust-backup.tar.gz -C /destination/path
   ```


## Updating the Application

To update the application:
1. Pull the latest changes:
   ```bash
   git pull origin main
   ```

2. Rebuild the Docker image:
   ```bash
   docker-compose build
   ```

3. Restart the container:
   ```bash
   docker-compose down
   docker-compose up -d
   ```
