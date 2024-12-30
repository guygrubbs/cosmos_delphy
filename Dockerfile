# Dockerfile for COSMOS CI/CD Environment with Modern Dependencies

FROM ubuntu:22.04

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUBY_VERSION=2.7.8
ENV BUNDLER_VERSION=1.17.3

# Install System Dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    qt5-default \
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
    rspec \
    && apt-get clean

# Install Specific Ruby Version and Bundler
RUN gem install bundler -v $BUNDLER_VERSION
RUN gem install rspec

# Set Ruby Alternatives to Ensure Compatibility
RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.7 1
RUN ruby -v && bundler -v && rspec --version

# Set Working Directory
WORKDIR /app

# Copy Project Files
COPY . /app

# Install Ruby Dependencies
RUN bundle _${BUNDLER_VERSION}_ install --jobs=4 --retry=3

# Validate Installation
RUN ruby -v && bundler -v && cmake --version && qmake --version && rspec --version

# Define Default Command
CMD ["/bin/bash"]
