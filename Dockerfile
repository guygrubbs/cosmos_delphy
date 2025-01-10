FROM ubuntu:18.04

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
  libx11-dev \
  libxext-dev \
  libxfixes-dev \
  libxrender-dev \
  libxcb1-dev \
  libxcb-glx0-dev \
  libyaml-dev \
  net-tools \
  qt4-default \
  qt4-dev-tools \
  ruby2.5 \
  ruby2.5-dev \
  vim \
  xvfb \
  zlib1g-dev

ENV COSMOS_VERSION=4.5.2

RUN gem install rake --no-document
RUN gem install rspec --no-document
RUN gem install bundler -v 1.17.3
RUN gem install cosmos -v ${COSMOS_VERSION} --no-document
RUN cosmos demo /cosmos

WORKDIR /cosmos

# Start Xvfb and run Launcher
CMD ["bash", "-c", "Xvfb :99 -screen 0 1024x768x24 & export DISPLAY=:99 && ruby Launcher"]