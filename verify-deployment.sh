#!/bin/bash

# Script to verify the deployed site is accessible and working
# Usage: ./verify-deployment.sh [URL]
# If no URL is provided, uses https://hoxmark.github.io

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default URL
SITE_URL="${1:-https://hoxmark.github.io}"

echo "================================"
echo "Verifying deployment at:"
echo "$SITE_URL"
echo "================================"
echo ""

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

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo -e "${RED}curl is required but not installed.${NC}"
    exit 1
fi

# Test main page
echo "Testing main page..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL")
if [ "$HTTP_CODE" = "200" ]; then
    print_status 0 "Main page accessible (HTTP $HTTP_CODE)"
else
    print_status 1 "Main page failed (HTTP $HTTP_CODE)"
fi

# Test blog page
echo "Testing blog page..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL/blog/")
if [ "$HTTP_CODE" = "200" ]; then
    print_status 0 "Blog page accessible (HTTP $HTTP_CODE)"
else
    print_warning "Blog page returned HTTP $HTTP_CODE"
fi

# Test projects page
echo "Testing projects page..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL/projects/")
if [ "$HTTP_CODE" = "200" ]; then
    print_status 0 "Projects page accessible (HTTP $HTTP_CODE)"
else
    print_warning "Projects page returned HTTP $HTTP_CODE"
fi

# Check for CSS
echo "Testing CSS files..."
CONTENT=$(curl -s "$SITE_URL")
if echo "$CONTENT" | grep -q "main.css"; then
    print_status 0 "CSS file referenced in HTML"
else
    print_warning "Could not find main.css reference"
fi

# Check for meta tags
echo "Checking meta tags..."
if echo "$CONTENT" | grep -q "<title>"; then
    print_status 0 "Title tag present"
else
    print_warning "Title tag not found"
fi

# Check response time
echo ""
echo "Testing response time..."
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$SITE_URL")
echo "Response time: ${RESPONSE_TIME}s"

if (( $(echo "$RESPONSE_TIME < 3" | bc -l) )); then
    print_status 0 "Response time acceptable (<3s)"
else
    print_warning "Response time is slow (>3s)"
fi

echo ""
echo "================================"
echo -e "${GREEN}Deployment verification complete!${NC}"
echo "================================"
echo ""
echo "Site URL: $SITE_URL"
echo "Status: Operational"
