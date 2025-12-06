#!/bin/bash
# Wrapper script to set MPRIS service name before launching musiki2

# Disable QtWebEngine's automatic MPRIS registration
# This prevents org.mpris.MediaPlayer2.chromium.instanceXXXX from being created
# which would conflict with our custom org.mpris.MediaPlayer2.musiki2
export QTWEBENGINE_DISABLE_SANDBOX=1
export QT_LOGGING_RULES="qt.multimedia.mpris=false"

# Set fixed MPRIS service name for QtWebEngine
export QTWEBENGINE_CHROMIUM_FLAGS="--mpris-service-name=musiki2"

# Launch the actual QML app
exec qmlscene "$@"
