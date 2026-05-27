#!/bin/bash

# Exit instantly if any single command fails
set -e

# Core Configuration
DOCKER_HUB_USER="bibekiam"
IMAGE_NAME="devops-dashboard"

echo "========================================="
echo "⚙️  Advanced Deployment Pipeline Config"
echo "========================================="

# 1. Ask the engineer what version tag they want to use
read -p "📝 Enter custom version tag (e.g., v2.1, hotfix, feature-xyz): " USER_TAG

# If the user just hits Enter, default it to a timestamp version
if [ -z "$USER_TAG" ]; then
    # Generates a dynamic tag using the current date and time (e.g., build-20260527-1423)
    TAG="build-$(date +%Y%m%d-%H%M)"
    echo "⚠️  No tag entered. Automatically generated timestamp tag: $TAG"
else
    TAG="$USER_TAG"
fi

echo ""
echo "========================================="
echo "🚀 Starting Automated Release Sequence [$TAG]..."
echo "========================================="

# 2. Rebuild the optimized image locally
echo "📦 Step 1: Rebuilding multi-stage production layers..."
docker build -t $IMAGE_NAME:latest .

# 3. Apply the custom tag AND a 'latest' backup tag
echo "🏷️  Step 2: Applying cloud tags..."
docker tag $IMAGE_NAME:latest $DOCKER_HUB_USER/$IMAGE_NAME:$TAG
docker tag $IMAGE_NAME:latest $DOCKER_HUB_USER/$IMAGE_NAME:latest

# 4. Push both versioned and latest images to Docker Hub Cloud
echo "☁️  Step 3: Pushing version tag [$TAG] to Docker Hub..."
docker push $DOCKER_HUB_USER/$IMAGE_NAME:$TAG

echo "☁️  Step 4: Updating [latest] rolling tag on Docker Hub..."
docker push $DOCKER_HUB_USER/$IMAGE_NAME:latest

echo "========================================="
echo "🎉 SUCCESS! Your application version $TAG is live."
echo "     👉 Cloud path: $DOCKER_HUB_USER/$IMAGE_NAME:$TAG"
echo "========================================="