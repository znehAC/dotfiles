#!/bin/bash

TARGET_COUNT=${1:-4}
PROFILE="candy"
MAX_RETRIES=30

echo "Iniciando OpenRGB Server..."
killall -9 openrgb 2>/dev/null
sleep 1

openrgb --server > /dev/null 2>&1 &
SERVER_PID=$!

echo "Aguardando detecção de $TARGET_COUNT dispositivos..."

RETRY=1
while [ $RETRY -le $MAX_RETRIES ]; do
    OUTPUT=$(openrgb --client --list-devices 2>&1)
    
    COUNT=$(echo "$OUTPUT" | grep "Received controller count" | awk -F': ' '{print $NF}' | tr -dc '0-9')

    if [ -z "$COUNT" ]; then
        COUNT=0
    fi

    echo "Status: Detectados $COUNT / $TARGET_COUNT (Tentativa $RETRY/$MAX_RETRIES)"

    if [ "$COUNT" -ge "$TARGET_COUNT" ]; then
        echo "Sucesso! $COUNT dispositivos encontrados."
        echo "Aplicando perfil..."
        openrgb --profile "$PROFILE" > /dev/null 2>&1
        
        # Lock do processo para o serviço Type=simple do Systemd não matar o servidor
        wait $SERVER_PID
        exit 0
    fi

    ((RETRY++))
    sleep 1
done

echo "Erro: Timeout atingido após $MAX_RETRIES tentativas. Encerrando."
kill -9 $SERVER_PID 2>/dev/null
exit 1
