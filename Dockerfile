# Dockerfile for COSMOS Deployment with Flexible Dependency Management

# Use the latest LTS Ubuntu version
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    qtbase5-dev \
    qtchooser \
    qt5-qmake \
    qtbase5-dev-tools \
    libqt5widgets5 \
    ruby-full \
    ruby-dev \
    bundler \
    git \
    curl \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxrender-dev \
    libxcb1-dev \
    libxcb-glx0-dev \
    && apt-get clean

# Verify system dependencies
RUN ruby -v && bundler -v && cmake --version && qmake --version

# Set working directory
WORKDIR /app

# Copy application files
COPY . /app

# Install Ruby gems using Bundler
RUN bundle install --jobs=4 --retry=3

# Validate installation
RUN ruby -v && bundler -v && rspec --version

# Expose any necessary ports (if applicable)
EXPOSE 8080

# Default command
CMD ["/bin/bash"]
