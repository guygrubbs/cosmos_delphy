# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

# Set environment variables
ENV COSMOS_VERSION=4.5.2
ENV APP_HOME=/cosmos
ENV DEBIAN_FRONTEND=noninteractive

# Install System Dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    cmake \
    freeglut3 \
    freeglut3-dev \
    gcc \
    g++ \
    git \
    iproute2 \
    libffi-dev \
    libgdbm-dev \
    libgdbm5 \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libncurses5-dev \
    libreadline6-dev \
    libsmokeqt4-dev \
    libssl-dev \
    libyaml-dev \
    net-tools \
    qt4-default \
    qt4-dev-tools \
    libqt4-opengl-dev \
    ruby2.5 \
    ruby2.5-dev \
    x11-apps \
    xvfb \
    vim \
    zlib1g-dev \
    && apt-get clean

# Install Ruby Gems and COSMOS
RUN gem install rake --no-document && \
    gem install bundler -v 1.17.3 --no-document && \
    gem install cosmos -v ${COSMOS_VERSION} --no-document

# Create a dedicated user for COSMOS
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN mkdir -p ${APP_HOME} && chown -R appuser:appuser ${APP_HOME}

# Switch to non-root user
USER appuser

# Initialize COSMOS demo environment if not already present
RUN if [ ! -d "${APP_HOME}/config" ]; then \
      cosmos demo ${APP_HOME}; \
    fi

# Set Working Directory
WORKDIR ${APP_HOME}

# Xvfb - Virtual X Server Setup
# - Starts an X11 display on :99 in the background
# - Allows graphical applications to run without a physical display
RUN echo '#!/bin/bash\n\
Xvfb :99 -screen 0 1024x768x24 &\n\
export DISPLAY=:99\n\
exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

# Validate installation
RUN ruby -v && cosmos --version

# Expose COSMOS default ports
EXPOSE 2900 2901 2902

# Set Entry Point
ENTRYPOINT ["/entrypoint.sh"]
CMD ["ruby", "Launcher"]
