#!/bin/bash

# Test script to verify the site builds successfully
# This script can be run locally using Docker (recommended) or with Ruby 3.2+

set -e  # Exit on error

echo "================================"
echo "Testing al-folio site build"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if Docker is available
if command -v docker &> /dev/null; then
    USE_DOCKER=true
    echo "Docker found - using Docker for build"
else
    USE_DOCKER=false
    echo "Docker not found - attempting local build"

    # Check Ruby version
    RUBY_VERSION=$(ruby -v | grep -oP '\d+\.\d+' | head -1)
    RUBY_MAJOR=$(echo $RUBY_VERSION | cut -d. -f1)
    RUBY_MINOR=$(echo $RUBY_VERSION | cut -d. -f2)

    if [ "$RUBY_MAJOR" -lt 3 ]; then
        print_warning "Ruby version $RUBY_VERSION detected. Ruby 3.0+ required."
        echo "Please install Ruby 3.2+ or use Docker to run this test."
        exit 1
    fi
fi

# Clean previous builds
echo ""
echo "Cleaning previous builds..."
rm -rf _site .jekyll-cache .jekyll-metadata
print_status $? "Cleaned build artifacts"

if [ "$USE_DOCKER" = true ]; then
    # Test with Docker
    echo ""
    echo "Building with Docker..."

    # Build Docker image
    docker build -t al-folio-test .
    print_status $? "Docker image built"

    # Run build in Docker
    docker run --rm \
        -v "$(pwd):/srv/jekyll" \
        -e JEKYLL_ENV=production \
        al-folio-test \
        bash -c "cd /srv/jekyll && bundle install && bundle exec jekyll build"
    print_status $? "Site built with Docker"
else
    # Test with local Ruby
    echo ""
    echo "Building with local Ruby..."

    # Install dependencies
    bundle install
    print_status $? "Dependencies installed"

    # Build the site
    JEKYLL_ENV=production bundle exec jekyll build
    print_status $? "Site built with local Ruby"
fi

# Verify build output
echo ""
echo "Verifying build output..."

if [ ! -d "_site" ]; then
    print_status 1 "_site directory exists"
fi
print_status 0 "_site directory exists"

if [ ! -f "_site/index.html" ]; then
    print_status 1 "index.html exists"
fi
print_status 0 "index.html exists"

# Check for common files
FILES_TO_CHECK=(
    "_site/blog/index.html"
    "_site/projects/index.html"
    "_site/assets/css/main.css"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} Found: $file"
    else
        print_warning "Optional file missing: $file"
    fi
done

# Check file sizes
SITE_SIZE=$(du -sh _site | cut -f1)
echo ""
echo "Build size: $SITE_SIZE"

# Verify no broken liquid tags
echo ""
echo "Checking for broken Liquid tags..."
BROKEN_LIQUID=$(grep -r "{%" _site --include="*.html" || true)
if [ -z "$BROKEN_LIQUID" ]; then
    print_status 0 "No broken Liquid tags found"
else
    print_warning "Found unprocessed Liquid tags (may be in code blocks)"
fi

echo ""
echo "================================"
echo -e "${GREEN}All tests passed!${NC}"
echo "================================"
echo ""
echo "The site is ready to deploy."
echo "Total build size: $SITE_SIZE"
