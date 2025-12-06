#!/bin/bash

echo "=== Musiki2 D-Bus Diagnostic Tool ==="
echo ""

echo "1. Checking registered D-Bus services..."
echo "Looking for org.mpris.MediaPlayer2.musiki2:"
dbus-send --session --print-reply \
  --dest=org.freedesktop.DBus \
  /org/freedesktop/DBus \
  org.freedesktop.DBus.ListNames | grep -i musiki2

echo ""
echo "2. Checking MPRIS path registration..."
echo "Introspecting /org/mpris/MediaPlayer2:"
gdbus introspect --session \
  --dest org.mpris.MediaPlayer2.musiki2 \
  --object-path /org/mpris/MediaPlayer2 2>&1 | head -20

echo ""
echo "3. Checking MediaHub session path registration..."
echo "Introspecting /com/lomiri/MediaHub/Service/sessions/0:"
gdbus introspect --session \
  --dest org.mpris.MediaPlayer2.musiki2 \
  --object-path /com/lomiri/MediaHub/Service/sessions/0 2>&1 | head -30

echo ""
echo "4. Looking for MediaHub service..."
dbus-send --session --print-reply \
  --dest=org.freedesktop.DBus \
  /org/freedesktop/DBus \
  org.freedesktop.DBus.ListNames | grep -i mediahub

echo ""
echo "=== Diagnostic Complete ==="
echo "Run this while musiki2 is playing music to see what's registered."
