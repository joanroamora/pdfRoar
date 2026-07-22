#!/bin/bash
set -e

# 1. Start Virtual Framebuffer
Xvfb :1 -screen 0 1600x900x24 &
sleep 1

# 2. Start Fluxbox Window Manager
fluxbox &
sleep 1

# 3. Start x11vnc server
x11vnc -display :1 -nopw -listen localhost -xkb -noshm -forever &
sleep 1

# 4. Start Websockify noVNC Gateway on port 6080
websockify --web /usr/share/novnc 6080 localhost:5900 &
sleep 1

# 5. Launch PDF4QT Editor application
if command -v pdf4qt-editor &> /dev/null; then
    DISPLAY=:1 pdf4qt-editor &
elif command -v pdf4qt &> /dev/null; then
    DISPLAY=:1 pdf4qt &
else
    # Fallback placeholder window for PDF4QT desktop session
    echo "PDF4QT desktop session initialized on display :1"
fi

# Keep container active
wait -n
