#!/bin/bash

PROFILE="candy"
TARGET_COUNT=3
MAX_RETRIES=25
HOST="127.0.0.1:6742"

# Give the server time to enumerate USB/HID devices (especially wireless ones)
sleep 10

LAST_COUNT=0
for ((i=1; i<=MAX_RETRIES; i++)); do
    OUTPUT=$(openrgb --client "$HOST" --list-devices 2>&1)

    if [ $? -ne 0 ]; then
        echo "Attempt $i/$MAX_RETRIES: Connection refused." >&2
    else
        COUNT=$(echo "$OUTPUT" | rg -o "Received controller count from server: \d+" | rg -o "\d+" | sort -rn | head -n 1)
        COUNT=${COUNT:-0}
        LAST_COUNT=$COUNT

        echo "Attempt $i/$MAX_RETRIES: Found $COUNT/$TARGET_COUNT..."
        if [ "$COUNT" -ge "$TARGET_COUNT" ]; then
            sleep 2
            openrgb --client "$HOST" -p "$PROFILE" > /dev/null 2>&1
            exit 0
        fi
    fi
    [[ $i -lt $MAX_RETRIES ]] && sleep 2
done

echo "Error: Target not reached after $MAX_RETRIES attempts (last count: $LAST_COUNT/$TARGET_COUNT)." >&2
exit 1
