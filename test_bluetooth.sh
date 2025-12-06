#!/bin/bash

echo "=== COMPREHENSIVE BLUETOOTH DEBUG TEST ==="
echo ""
echo "This script monitors D-Bus while you press your Bluetooth button."
echo "We'll see exactly where the signal goes."
echo ""
echo "1. Open your musiki2 app and start playing music"
echo "2. In another terminal, run this script"
echo "3. Press your Bluetooth headset button"
echo "4. Watch the output"
echo ""
read -p "Press ENTER when ready to start monitoring..."

echo ""
echo "=== Starting D-Bus Monitor ==="
echo "Monitoring for Bluetooth media key events..."
echo ""

# Monitor all D-Bus activity related to media and telephony
dbus-monitor --session "interface='com.lomiri.TelephonyServiceApprover',interface='org.mpris.MediaPlayer2.Player',path='/com/lomiri/MediaHub/Service/sessions/0'" &
MONITOR_PID=$!

echo "Monitoring started (PID: $MONITOR_PID)"
echo ""
echo "Now press your Bluetooth button and watch for D-Bus messages..."
echo "Press Ctrl+C to stop monitoring"
echo ""

# Wait for user to stop
wait $MONITOR_PID
