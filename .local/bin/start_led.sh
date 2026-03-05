#!/bin/bash

TARGET_COUNT=4
PROFILE="candy"

pkill -9 openrgb 2>/dev/null

openrgb --server > /dev/null 2>&1 &
SERVER_PID=$!

sleep 5

for i in {1..30}; do
    COUNT=$(openrgb --client --list-devices | grep -c "Device index")
    if [ "$COUNT" -ge "$TARGET_COUNT" ]; then
        openrgb --profile "$PROFILE"
        echo "Perfil $PROFILE aplicado com sucesso em $COUNT dispositivos."
        wait $SERVER_PID
        exit 0
    fi
    sleep 2
done

echo "Timeout: Apenas $COUNT dispositivos encontrados."
exit 1
