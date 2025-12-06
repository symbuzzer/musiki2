#!/bin/bash
# Launcher script for musiki2 with Bluetooth support

# Start the Bluetooth monitor in the background
nohup /opt/click.ubuntu.com/musiki2.symbuzzer/current/bluetooth_monitor.sh >/dev/null 2>&1 &
MONITOR_PID=$!

echo "Bluetooth monitor started (PID: $MONITOR_PID)"

# Launch the main app
exec qmlscene "$@" qml/Main.qml
