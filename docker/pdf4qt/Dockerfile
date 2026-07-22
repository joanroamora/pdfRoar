# ==========================================================================
   pdfRoar - PDF4QT Native Web Studio Container
   Runs PDF4QT Editor GUI inside Xvfb + noVNC for browser-native access
   ========================================================================== #

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Install X11, fluxbox WM, x11vnc, websockify, noVNC, and Qt6 dependencies
RUN apt-get update && apt-get install -y \
    xvfb \
    fluxbox \
    x11vnc \
    websockify \
    novnc \
    git \
    cmake \
    build-essential \
    qt6-base-dev \
    qt6-tools-dev \
    libqt6svg6-dev \
    wget \
    curl \
    python3 \
    supervisor \
    && rm -rf /var/lib/apt-get/lists/*

# Setup noVNC web interface
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Copy Startup Supervisor Config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080 5900

ENTRYPOINT ["/entrypoint.sh"]
