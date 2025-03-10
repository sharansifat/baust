#!/bin/bash

# Exit on error
set -e

# Set GitHub repository URL
GITHUB_REPO="https://github.com/sharansifat/baust.git"

# Add all files to git
git add .

# Commit changes
git commit -m "Initial commit for Ubuntu with Docker deployment" --allow-empty

# Set the remote repository
git remote remove origin 2>/dev/null || true
git remote add origin ${GITHUB_REPO}

# Force push to GitHub (this will override any existing content)
git push -u origin main --force

echo "Successfully pushed to GitHub!"
echo "Repository URL: ${GITHUB_REPO}"
