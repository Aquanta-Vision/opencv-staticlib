#!/bin/bash

# Exit on error
set -e

# Get the directory containing this script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

echo "Building Docker image..."
docker build -t opencv-staticlib-builder "$SCRIPT_DIR"

echo "Running build in Docker container..."
docker run --rm \
  -v "$SCRIPT_DIR:/workspace" \
  -v "$HOME:$HOME" \
  -e HOME="$HOME" \
  opencv-staticlib-builder \
  /workspace/install_linux.sh

echo "Build completed successfully!"
echo "Check the x86_64/ and aarch64/ directories for the built libraries"
