#!/bin/bash
# Bluetooth Media Key Monitor for musiki2
# This script monitors D-Bus for Bluetooth button presses and triggers musiki2

echo "Starting Bluetooth media key monitor for musiki2..."

# Monitor D-Bus for HandleMediaKey calls
dbus-monitor --session "type='method_call',interface='com.lomiri.TelephonyServiceApprover',member='HandleMediaKey'" | \
while read -r line; do
    if echo "$line" | grep -q "HandleMediaKey"; then
        echo "Bluetooth button detected! Triggering PlayPause..."
        
        # Call PlayPause on musiki2's MPRIS interface
        gdbus call --session \
            --dest org.mpris.MediaPlayer2.musiki2 \
            --object-path /org/mpris/MediaPlayer2 \
            --method org.mpris.MediaPlayer2.Player.PlayPause 2>/dev/null
            
        echo "PlayPause triggered"
    fi
done
