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

# Install specific Ruby version (2.7.8)
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.7 ruby2.7-dev && \
    gem install bundler -v 1.17.3 && \
    gem install rspec

# Set Ruby 2.7.8 as default
RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.7 1
RUN ruby -v

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Install Ruby dependencies with Bundler
RUN bundle _1.17.3_ install --jobs=4 --retry=3

# Validate installation
RUN ruby -v && bundler -v && cmake --version && qmake --version && rspec --version

CMD ["/bin/bash"]
