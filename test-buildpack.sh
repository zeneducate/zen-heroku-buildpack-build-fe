#!/usr/bin/env bash
# Test script for the frontend buildpack

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Frontend Buildpack Test Script${NC}"
echo "================================"
echo ""

# Check if app path is provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: Please provide the path to your app${NC}"
  echo "Usage: ./test-buildpack.sh /path/to/your/app"
  echo ""
  echo "Example: ./test-buildpack.sh ../zen-educate-app"
  exit 1
fi

APP_DIR=$(cd "$1" && pwd)

if [ ! -d "$APP_DIR/web" ]; then
  echo -e "${RED}Error: No web directory found in $APP_DIR${NC}"
  exit 1
fi

# Create temporary directories to simulate Heroku environment
TEST_DIR=$(mktemp -d)
BUILD_DIR="$TEST_DIR/build"
CACHE_DIR="$TEST_DIR/cache"
ENV_DIR="$TEST_DIR/env"

echo -e "${YELLOW}Setting up test environment...${NC}"
echo "Build dir: $BUILD_DIR"
echo "Cache dir: $CACHE_DIR"
echo "Env dir:   $ENV_DIR"
echo ""

# Copy app to build directory
cp -R "$APP_DIR" "$BUILD_DIR"
mkdir -p "$CACHE_DIR"
mkdir -p "$ENV_DIR"

# Set up test environment variables (customize these as needed)
# Example WEB_ variables - add your own as needed
echo "review" > "$ENV_DIR/SERVER_NAME"
echo "zeneducate-pr-224" > "$ENV_DIR/HEROKU_APP_NAME"

# Add any WEB_ prefixed env vars you need for the build
# echo "your-value" > "$ENV_DIR/WEB_SOME_VAR"

echo -e "${YELLOW}Running buildpack...${NC}"
echo ""

# Run the buildpack
BUILDPACK_DIR=$(cd "$(dirname "$0")" && pwd)
"$BUILDPACK_DIR/bin/compile" "$BUILD_DIR" "$CACHE_DIR" "$ENV_DIR"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}✓ Buildpack completed successfully!${NC}"
  echo ""
  echo "Build artifacts location: $BUILD_DIR/web/dist"
  echo "Cache location: $CACHE_DIR"
  echo ""
  echo "Checking build output..."
  if [ -d "$BUILD_DIR/web/dist" ]; then
    echo -e "${GREEN}✓ dist directory exists${NC}"
    ls -lh "$BUILD_DIR/web/dist"
  else
    echo -e "${RED}✗ dist directory not found${NC}"
  fi
  echo ""
  echo -e "${YELLOW}Test environment preserved at: $TEST_DIR${NC}"
  echo "To inspect: cd $TEST_DIR"
  echo "To clean up: rm -rf $TEST_DIR"
else
  echo -e "${RED}✗ Buildpack failed with exit code $EXIT_CODE${NC}"
  echo ""
  echo -e "${YELLOW}Test environment preserved at: $TEST_DIR${NC}"
  echo "To inspect: cd $TEST_DIR"
  echo "To clean up: rm -rf $TEST_DIR"
  exit $EXIT_CODE
fi
