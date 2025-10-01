#!/bin/bash
# Script to list all available versions of the Docker image

set -e

# Configuration
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-cj445}"
IMAGE_NAME="${IMAGE_NAME:-cj445/ci-cd-automation}"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# List local images
print_header "Local Docker Images"
docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"

echo ""

# List remote tags (requires jq)
print_header "DockerHub Information"
echo "Repository: https://hub.docker.com/r/$IMAGE_NAME"
echo "Tags: https://hub.docker.com/r/$IMAGE_NAME/tags"

echo ""

# If curl and jq are available, fetch tag information
if command -v curl &> /dev/null && command -v jq &> /dev/null; then
    print_info "Fetching latest tags from DockerHub..."

    # Fetch tags (limited to first 100)
    TAGS=$(curl -s "https://hub.docker.com/v2/repositories/$IMAGE_NAME/tags/?page_size=100" | jq -r '.results[] | "\(.name)\t\(.last_updated)"' 2>/dev/null || echo "")

    if [ -n "$TAGS" ]; then
        echo -e "Tag\t\tLast Updated"
        echo "$TAGS" | head -20
    else
        echo "Unable to fetch tags. Check repository exists and is public."
    fi
else
    print_info "Install 'jq' to fetch remote tags: sudo apt-get install jq"
fi
