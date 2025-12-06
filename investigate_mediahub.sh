#!/bin/bash

echo "=== Investigating MediaHub and Bluetooth Routing ==="
echo ""

echo "1. What's the real MediaHub service structure?"
gdbus introspect --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path / 2>&1 | head -50

echo ""
echo "2. Let's see MediaHub's full tree:"
gdbus introspect --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path /com/lomiri/MediaHub 2>&1 | head -50

echo ""
echo "3. Check if there's a Service object:"
gdbus introspect --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path /com/lomiri/MediaHub/Service 2>&1 | head -80

echo ""
echo "4. What sessions does MediaHub know about?"
gdbus call --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path /com/lomiri/MediaHub/Service \
  --method org.freedesktop.DBus.Introspectable.Introspect 2>&1

echo ""
echo "=== End Investigation ==="
