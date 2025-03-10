#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print a message with a color
print_message() {
    echo -e "${2}$1${NC}"
}

# Set GitHub repository URL
GITHUB_REPO="https://github.com/sharansifat/baust.git"

# Confirm before proceeding
print_message "This script will push all content to: ${GITHUB_REPO}" "$YELLOW"
print_message "Warning: This will overwrite any existing content in the repository." "$RED"
read -p "Do you want to continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_message "Operation cancelled." "$RED"
    exit 1
fi

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    print_message "Initializing git repository..." "$YELLOW"
    git init
fi

# Add all files to git
print_message "Adding files to git..." "$YELLOW"
git add .

# Commit changes
print_message "Committing changes..." "$YELLOW"
git commit -m "Initial commit for Ubuntu with Docker deployment"

# Set the remote repository
print_message "Setting remote repository..." "$YELLOW"
git remote remove origin 2>/dev/null || true
git remote add origin ${GITHUB_REPO}

# Push to GitHub
print_message "Pushing to GitHub..." "$YELLOW"
git push -u origin main --force

print_message "Successfully pushed to GitHub!" "$GREEN"
print_message "Repository URL: ${GITHUB_REPO}" "$GREEN"
