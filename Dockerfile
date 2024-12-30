# Dockerfile for COSMOS CI Environment with Qt4
FROM ubuntu:20.04

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libqt4-dev \
    ruby-full \
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
    rspec \
    && apt-get clean

# Install Bundler 1.17.3
RUN gem install bundler -v 1.17.3

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Install Ruby dependencies
RUN bundle _1.17.3_ install

# Validate installation
RUN ruby -v && bundler -v && qmake --version && cmake --version

CMD ["/bin/bash"]
