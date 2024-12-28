#!/usr/bin/env bash
# This script allows me to run a web server that provides data for my bot (for monitoring servers)
set -o allexport

## include library
source $(dirname "$0")/pc.lib.sh        # Lib of functions to get local server metrics
source $(dirname "$0")/docker.lib.sh    # Lib of functions to get docker metrics

if [ -f .env.sh ]; then
    source $(dirname "$0")/.env.sh
else
    source $(dirname "$0")/default.env.sh
fi

source $(dirname "$0")/websrv.lib.sh    # Lib of functions to run netcat web server

## Preliminary check of launch conditions.
## check PID file existence
if [ -f /var/run/${APP_NAME}.pid ]; then
    echo "$APP_NAME ERROR: PID file (/var/run/${APP_NAME}.pid) already exists. Therefore, the process is already running or was not terminated correctly." >&2
    exit 1
else
    ## check if port is busy
    if nc -vz $SRV_ADDR $SRV_PORT > /dev/null 2>&1; then
        echo "$APP_NAME ERROR: Port $SRV_PORT on address $SRV_ADDR already in use" >&2
        exit 1
    fi
    ## save pid to file
    echo $$ > /var/run/${APP_NAME}.pid
fi

exporter_data(){
    ## Directly the function that generates data for sending to the web server.
    data=$(pc_get_all)

    if docker_check_requirement; then
        docker_data=$(echo "{\"Docker\": {\"containers\":$(docker_get_containers|jq --slurp --compact-output),\"usage\":$(docker_get_resource_usage|jq --slurp --compact-output)}}")
        data=$(echo "$data" |\
            jq --argjson docker "$docker_data" '. + $docker')
    fi
    data=$(echo "$data" |\
        jq --slurp --monochrome-output --indent 2)
    if [ $BASE_64 -eq 1 ]; then
        data=$(echo "$data"| base64)
    fi
    echo "$data"
}

websrv_run