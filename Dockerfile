FROM ubuntu:18.04

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    pkg-config \
    # Cross-compilation tools for ARM64
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    # OpenCV dependencies
    libgtk2.0-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    # Image format libraries
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    # Additional dependencies
    zlib1g-dev \
    libopenexr-dev \
    && rm -rf /var/lib/apt/lists/*

# Show GLIBC version for reference
RUN ldd --version

# Set working directory
WORKDIR /workspace

# Copy the repository contents
COPY . /workspace/

# Make the build script executable
RUN chmod +x install_linux.sh

# Default command
CMD ["/bin/bash"]
