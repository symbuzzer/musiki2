#!/bin/bash

echo "=== Investigating MediaHub Session Control Flow ==="
echo ""

echo "1. What happens when we call Play() on a MediaHub session?"
echo "   Creating a test session first..."
RESULT=$(gdbus call --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path /com/lomiri/MediaHub/Service \
  --method com.lomiri.MediaHub.Service.CreateFixedSession \
  "test-investigation")

SESSION_PATH=$(echo "$RESULT" | grep -oP "'/[^']+'" | tr -d "'")
echo "   Session created: $SESSION_PATH"
echo ""

echo "2. Try calling Play() on this session..."
gdbus call --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path "$SESSION_PATH" \
  --method org.mpris.MediaPlayer2.Player.Play 2>&1

echo ""
echo "3. Does MediaHub have a way to set a URI or backend?"
echo "   Checking OpenUri method..."
gdbus introspect --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path "$SESSION_PATH" | grep -A5 "OpenUri"

echo ""
echo "4. What about monitoring the session for signals?"
echo "   Let's see what signals it has..."
gdbus introspect --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path "$SESSION_PATH" | grep -A2 "signals:"

echo ""
echo "5. Check if there's a way to get the 'current' or 'focused' session..."
gdbus introspect --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path /com/lomiri/MediaHub/Service | grep -i "focus\|current\|active"

echo ""
echo "=== Investigation Complete ==="
echo ""
echo "THEORY: Maybe we need to monitor MediaHub session signals and forward"
echo "        commands to our app, OR find a way to make MediaHub use our"
echo "        MPRIS service as its backend."
