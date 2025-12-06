#!/bin/bash

echo "=== Testing MediaHub Session Creation ==="
echo ""

echo "1. Creating a session with MediaHub Service..."
RESULT=$(gdbus call --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path /com/lomiri/MediaHub/Service \
  --method com.lomiri.MediaHub.Service.CreateSession)

echo "Result: $RESULT"
echo ""

# Parse the result to get object path and UUID
# Format will be like: (objectpath '/com/lomiri/MediaHub/Service/sessions/123', 'uuid-here')
SESSION_PATH=$(echo "$RESULT" | grep -oP "'/[^']+'" | head -1 | tr -d "'")
SESSION_UUID=$(echo "$RESULT" | grep -oP "'[0-9a-f-]+'" | tail -1 | tr -d "'")

echo "Session Path: $SESSION_PATH"
echo "Session UUID: $SESSION_UUID"
echo ""

echo "2. Let's introspect this session..."
if [ ! -z "$SESSION_PATH" ]; then
    gdbus introspect --session \
      --dest com.lomiri.MediaHub.Service \
      --object-path "$SESSION_PATH" | head -50
fi

echo ""
echo "3. Now test with CreateFixedSession (named session)..."
FIXED_RESULT=$(gdbus call --session \
  --dest com.lomiri.MediaHub.Service \
  --object-path /com/lomiri/MediaHub/Service \
  --method com.lomiri.MediaHub.Service.CreateFixedSession \
  "musiki2-test")

echo "Fixed Session Result: $FIXED_RESULT"

echo ""
echo "=== This shows us what a proper MediaHub session looks like! ==="
