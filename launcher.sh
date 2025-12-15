#!/bin/bash
# Launcher script for musiki2 with Bluetooth support

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start the Bluetooth monitor in the background
nohup "$SCRIPT_DIR/bluetooth_monitor.sh" >/dev/null 2>&1 &
MONITOR_PID=$!

echo "Bluetooth monitor started (PID: $MONITOR_PID)"

# Launch the main app
exec qmlscene "$@" qml/Main.qml
