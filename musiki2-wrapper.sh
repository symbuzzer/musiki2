#!/bin/bash
# Wrapper script to set MPRIS service name before launching musiki2

# Set fixed MPRIS service name for QtWebEngine
export QTWEBENGINE_CHROMIUM_FLAGS="--mpris-service-name=musiki2"

# Launch the actual QML app
exec qmlscene "$@"
