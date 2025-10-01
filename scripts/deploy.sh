#!/bin/bash
# Deployment Script for CI/CD Demo Application
# This script deploys a specific version of the Docker image

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-cj445}"
IMAGE_NAME="${IMAGE_NAME:-cj445/ci-cd-automation}"
CONTAINER_NAME="${CONTAINER_NAME:-cicd-demo-app}"
PORT="${PORT:-5000}"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --tag TAG        Docker image tag to deploy (default: latest)"
    echo "  -p, --port PORT      Host port to expose (default: 5000)"
    echo "  -n, --name NAME      Container name (default: cicd-demo-app)"
    echo "  -h, --help           Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --tag v1.0.0"
    echo "  $0 --tag latest --port 8080"
    echo "  $0 --tag main-abc123f"
    exit 1
}

# Parse command line arguments
TAG="latest"
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Main deployment process
print_info "Starting deployment of $IMAGE_NAME:$TAG"

# Step 1: Pull the latest image
print_info "Pulling Docker image: $IMAGE_NAME:$TAG"
if docker pull "$IMAGE_NAME:$TAG"; then
    print_info "Image pulled successfully"
else
    print_error "Failed to pull image"
    exit 1
fi

# Step 2: Stop and remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_warning "Stopping existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" || true
    print_warning "Removing existing container: $CONTAINER_NAME"
    docker rm "$CONTAINER_NAME" || true
fi

# Step 3: Run the new container
print_info "Starting new container: $CONTAINER_NAME"
docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$PORT:5000" \
    -e "ENVIRONMENT=production" \
    -e "APP_VERSION=$TAG" \
    --restart unless-stopped \
    "$IMAGE_NAME:$TAG"

# Step 4: Wait for container to be healthy
print_info "Waiting for container to be healthy..."
sleep 5

# Step 5: Health check
print_info "Performing health check..."
for i in {1..10}; do
    if curl -f -s "http://localhost:$PORT/health" > /dev/null; then
        print_info "Health check passed!"
        print_info "✓ Deployment successful!"
        print_info "Container: $CONTAINER_NAME"
        print_info "Image: $IMAGE_NAME:$TAG"
        print_info "URL: http://localhost:$PORT"

        # Display container info
        echo ""
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

        exit 0
    fi
    print_warning "Health check attempt $i/10 failed, retrying..."
    sleep 3
done

print_error "Health check failed after 10 attempts"
print_error "Container logs:"
docker logs "$CONTAINER_NAME"
exit 1
