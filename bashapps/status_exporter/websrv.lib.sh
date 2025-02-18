#!/usr/bin/env bash
# this is netcat web server.
# Require: netcat

# This command is needed for the correct operation of the web server.
# It allows to pass variable values ​​to netcat running together with timeout.
set -o allexport

__WEBSRV_LIB__=true

EXPORTER_DATA=''
c_time=0

if [ $SRV_PORT -le 0 ]; then
    if [ -f .env.sh ]; then
        source $(dirname "$0")/.env.sh
    else
        source $(dirname "$0")/default.env.sh
    fi
fi

## http header
if [ $BASE_64 -eq 1 ]; then
    content_type="text/plain"
else
    content_type="application/json;"
fi

SRV_HEADER="HTTP/1.1 200 Everything Is Just Fine
Server: Stat Exporter
Content-Type: $content_type; charset=UTF-8"



web_check_requirement(){
    ### check system requirements
    if ! command -v nc > /dev/null 2>&1; then
        echo "netcat - is not installed"
        return 1
    fi
    return 0
}

websrv_iteration(){
    ## function open web socket and wait for request
    if [[ $SERVICESTATUS == 0 ]]; then
        echo -e "${SRV_HEADER}\n\n${EXPORTER_DATA}\n" | nc -l -s $SRV_ADDR -p $SRV_PORT -q 1 > /dev/null 2>&1
    else
        echo -e "${SRV_HEADER}\n\n${EXPORTER_DATA}\n" | nc -l -s $SRV_ADDR -p $SRV_PORT -q 1 -v
    fi
}

websrv_run(){
    while true; do
        if [[ $(( $c_time + $RENEW_TIMEOUT )) -le $(date +%s) ]]; then
            c_time=$(date +%s)
            ## generate exporter data
            EXPORTER_DATA=$(exporter_data)
        fi
        ## start the server every ${SRV_TIMEOUT}.
        if [[ $SRV_TIMEOUT == 0 ]]; then
            ## >> Stable algorithm, but to get up-to-date data, you need to request it twice.. <<
            websrv_iteration
        else
            ## >> Unstable algorithm, but up-to-date data. <<
            timeout --preserve-status ${SRV_TIMEOUT} bash -c websrv_iteration
        fi
    done
}