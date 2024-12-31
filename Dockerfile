# Dockerfile for COSMOS v4 Deployment with Ruby 2.5 and Ubuntu 18.04

FROM ubuntu:18.04

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive
ENV COSMOS_VERSION=4.5.2
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install System Dependencies
RUN apt-get update -y && apt-get install -y \
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
    ruby2.5 \
    ruby2.5-dev \
    rake \
    vim \
    zlib1g-dev \
    && apt-get clean

# Set Default Ruby Version
RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.5 1
RUN update-alternatives --set ruby /usr/bin/ruby2.5

# Install Bundler
RUN gem install bundler -v 1.17.3 --no-document

# Install Rake Explicitly
RUN gem install rake -v 12.3.1 --no-document

# Verify Ruby and Gems
RUN ruby -v && bundler -v && rake --version

# Install COSMOS
RUN gem install cosmos -v ${COSMOS_VERSION} --no-document || \
    (echo "Retrying COSMOS installation after Rake re-setup" && \
    gem install rake -v 12.3.1 --no-document && \
    gem install cosmos -v ${COSMOS_VERSION} --no-document)

# Set Working Directory
WORKDIR /cosmos

# Copy Application Files
COPY . /cosmos

# Install Ruby Dependencies
RUN bundle _1.17.3_ install --jobs=4 --retry=3

# Validate Installation
RUN ruby -v && bundler -v && rake --version && cmake --version && qmake --version

# Expose Default COSMOS Port (if required)
EXPOSE 2900

# Start COSMOS Launcher
CMD ["ruby", "Launcher"]