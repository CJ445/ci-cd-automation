#!/bin/bash
# Rollback Script for CI/CD Demo Application
# This script rolls back to a previous version of the Docker image

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --tag TAG        Docker image tag to rollback to (required)"
    echo "  -l, --list           List available image tags"
    echo "  -c, --current        Show currently running version"
    echo "  -h, --help           Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --list                    # List available versions"
    echo "  $0 --current                 # Show current version"
    echo "  $0 --tag v1.0.0              # Rollback to v1.0.0"
    echo "  $0 --tag main-abc123f        # Rollback to specific commit"
    exit 1
}

# Function to get current running version
get_current_version() {
    if docker ps --filter "name=$CONTAINER_NAME" --format '{{.Image}}' | grep -q .; then
        CURRENT_IMAGE=$(docker ps --filter "name=$CONTAINER_NAME" --format '{{.Image}}')
        print_info "Currently running: $CURRENT_IMAGE"

        # Get version from running container
        CURRENT_VERSION=$(docker exec "$CONTAINER_NAME" python -c "import os; print(os.getenv('APP_VERSION', 'unknown'))" 2>/dev/null || echo "unknown")
        print_info "Version: $CURRENT_VERSION"
    else
        print_warning "No container currently running with name: $CONTAINER_NAME"
    fi
}

# Function to list available tags from DockerHub
list_available_tags() {
    print_header "Fetching available tags for $IMAGE_NAME..."

    # Try to get tags from local images
    print_info "Local images:"
    docker images "$IMAGE_NAME" --format "table {{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}" | head -20

    echo ""
    print_info "To see all tags on DockerHub, visit:"
    echo "https://hub.docker.com/r/$IMAGE_NAME/tags"
}

# Function to create backup of current deployment
create_backup() {
    if docker ps --filter "name=$CONTAINER_NAME" --format '{{.Image}}' | grep -q .; then
        CURRENT_IMAGE=$(docker ps --filter "name=$CONTAINER_NAME" --format '{{.Image}}')
        BACKUP_NAME="${CONTAINER_NAME}-backup-$(date +%Y%m%d-%H%M%S)"

        print_info "Creating backup container: $BACKUP_NAME"
        docker commit "$CONTAINER_NAME" "$BACKUP_NAME" > /dev/null
        print_info "Backup created successfully"
        echo "$BACKUP_NAME" > /tmp/cicd-rollback-backup.txt
    fi
}

# Function to perform rollback
perform_rollback() {
    local target_tag=$1

    print_header "=== ROLLBACK OPERATION ==="
    print_warning "This will rollback to: $IMAGE_NAME:$target_tag"

    # Create backup before rollback
    create_backup

    # Pull the target image
    print_info "Pulling image: $IMAGE_NAME:$target_tag"
    if ! docker pull "$IMAGE_NAME:$target_tag"; then
        print_error "Failed to pull image: $IMAGE_NAME:$target_tag"
        exit 1
    fi

    # Stop current container
    if docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_info "Stopping current container..."
        docker stop "$CONTAINER_NAME" || true
        docker rm "$CONTAINER_NAME" || true
    fi

    # Start container with rollback version
    print_info "Starting container with rollback version..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p "$PORT:5000" \
        -e "ENVIRONMENT=production" \
        -e "APP_VERSION=$target_tag" \
        --restart unless-stopped \
        "$IMAGE_NAME:$target_tag"

    # Health check
    print_info "Performing health check..."
    sleep 5

    for i in {1..10}; do
        if curl -f -s "http://localhost:$PORT/health" > /dev/null; then
            print_info "✓ Rollback successful!"
            print_info "Container: $CONTAINER_NAME"
            print_info "Image: $IMAGE_NAME:$target_tag"
            print_info "URL: http://localhost:$PORT"

            # Verify version
            RUNNING_VERSION=$(curl -s "http://localhost:$PORT" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
            print_info "Running version: $RUNNING_VERSION"

            return 0
        fi
        print_warning "Health check attempt $i/10 failed, retrying..."
        sleep 3
    done

    print_error "Rollback health check failed!"
    print_error "Attempting to restore backup..."
    restore_backup
    exit 1
}

# Function to restore from backup
restore_backup() {
    if [ -f /tmp/cicd-rollback-backup.txt ]; then
        BACKUP_NAME=$(cat /tmp/cicd-rollback-backup.txt)
        print_warning "Restoring from backup: $BACKUP_NAME"

        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true

        docker run -d \
            --name "$CONTAINER_NAME" \
            -p "$PORT:5000" \
            --restart unless-stopped \
            "$BACKUP_NAME"

        print_info "Backup restored"
        rm /tmp/cicd-rollback-backup.txt
    else
        print_error "No backup available"
    fi
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TARGET_TAG="$2"
            shift 2
            ;;
        -l|--list)
            list_available_tags
            exit 0
            ;;
        -c|--current)
            get_current_version
            exit 0
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

# Validate target tag is provided
if [ -z "$TARGET_TAG" ]; then
    print_error "Target tag is required"
    usage
fi

# Confirm rollback
print_header "Current deployment:"
get_current_version
echo ""

read -p "Are you sure you want to rollback to $TARGET_TAG? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    print_warning "Rollback cancelled"
    exit 0
fi

# Perform rollback
perform_rollback "$TARGET_TAG"
