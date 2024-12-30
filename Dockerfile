# Dockerfile for COSMOS CI Environment with Qt5 and RSpec

FROM ubuntu:20.04

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    qt5-default \
    libqt5widgets5 \
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
    && apt-get clean

# Install Ruby Gems
RUN gem install bundler -v 1.17.3
RUN gem install rspec

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Install Ruby dependencies
RUN bundle _1.17.3_ install

# Validate installation
RUN ruby -v && bundler -v && cmake --version && qmake --version

CMD ["/bin/bash"]
