# Use a base Ubuntu image
FROM ubuntu:18.04

# Set Environment Variables
ENV COSMOS_VERSION=4.5.2
ENV APP_HOME=/cosmos
ENV DISPLAY=:99

# Install System Dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    qt4-default \
    qt4-dev-tools \
    libqt4-dev \
    libqt4-opengl-dev \
    ruby2.5 \
    ruby2.5-dev \
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
    xvfb \
    && apt-get clean

# Install Ruby Gems
RUN gem install bundler -v 1.17.3 --no-document

# Create Application Directory
WORKDIR ${APP_HOME}

# Install Ruby Dependencies
RUN bundle _1.17.3_ install --jobs=4 --retry=3

# Install COSMOS
RUN gem install cosmos -v ${COSMOS_VERSION} --no-document

# Ensure /cosmos does not pre-exist and create a fresh one
RUN if [ -d "${APP_HOME}" ]; then rm -rf ${APP_HOME}; fi && \
    mkdir -p ${APP_HOME} && \
    cosmos demo ${APP_HOME}

# Set Working Directory
WORKDIR ${APP_HOME}

# Start Xvfb and run Launcher
CMD ["bash", "-c", "Xvfb :99 -screen 0 1024x768x24 & export DISPLAY=:99 && ruby Launcher"]
