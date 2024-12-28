#!/usr/bin/env bash
# run this script to stop netcat server

# 
if [[ $SRV_PORT -le 0 ]]; then
    if [ -f .env.sh ]; then
        source $(dirname "$0")/.env.sh
    else
        source $(dirname "$0")/default.env.sh
    fi
fi

## check PID file existence
if [ -f ${PID_FILE_DIR}/${APP_NAME}.pid ]; then
    ## get PID from file --> kill PID --> remove PID file --> send request to server to stop current iteration
    pid=$(cat ${PID_FILE_DIR}/${APP_NAME}.pid)
    kill $pid
    rm ${PID_FILE_DIR}/${APP_NAME}.pid
    nc -vz $SRV_ADDR $SRV_PORT
else
    echo "PID-file not found"
fi
