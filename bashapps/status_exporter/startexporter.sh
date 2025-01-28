#!/usr/bin/env bash
# This script allows me to run a web server that provides data for my bot (for monitoring servers)

## This command is needed for the correct operation of the web server.
## It allows to pass variable values ​​to netcat running together with timeout.
## Uncomment if you have problems with correct data output from netcat.
set -o allexport

# include configuration file
if [ -f .env.sh ]; then
    source $(dirname "$0")/.env.sh
else
    source $(dirname "$0")/default.env.sh
fi

## help function
print_help(){
    local cmd="$1"
    echo
    echo -e "A simple utility for getting metrics and providing them in JSON format.\n"
    echo -e "Usage:"
    echo -e "  1) Edit the \".env.sh\" file to set the correct settings."
    echo -e "  2) Run \"$cmd\" to run as a normal service (a netcat-based web server will be started and the metrics will be updated every $RENEW_TIMEOUT seconds)\n     or use the following command line arguments to change the functionality:"
    echo -e "\t -h|--help\t To print this message."
    echo -e "\t -f <filename>\t To use file <filename> to output all metrics."
    echo -e "\t service\t Use it when running as a systemd unit to reduce output."
    ## The "server" functionality is not ready.
    # echo -e "\t server \t Should be used with -f together. Will run web server only and return content of the file as an answer."
    echo
    echo -e "Read Readme.md for more information.\n"
    exit 0
}

## Process command line arguments to understand the operating mode.
SERVICESTATUS=1
SERVERSTATUS=1
FILENAME=""

# Iterating over command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_help "$0"
        ;;
        server)
            SERVERSTATUS=0
            shift
        ;;
        service)
            SERVICESTATUS=0
            shift
        ;;
        -f)
            FILENAME=$2
            shift 2
        ;;
        *)
            # in case of unknown argument do nothing
            shift
          ;;
    esac
done

## include library to collect metrics
source $(dirname "$0")/pc.lib.sh        # Lib of functions to get local server metrics
source $(dirname "$0")/docker.lib.sh    # Lib of functions to get docker metrics
source $(dirname "$0")/rpi4_argon.lib.sh # Lib of functions to get Raspberry Pi 4 in Argone case specific metrics

exporter_data(){
    ## Directly the function that generates data for sending to the web server.
    data=$(pc_get_all)
    
    if docker_check_requirement; then
        docker_data=$(echo "{\"Docker\": {\"containers\":$(docker_get_containers|jq --slurp --compact-output),\"usage\":$(docker_get_resource_usage|jq --slurp --compact-output)}}")
        data=$(echo "$data" |\
            jq --argjson docker "$docker_data" '. + $docker')
    fi
    if rpi4_check_requirement; then
        # rpi4_data=$(get_rpi_metrics|jq '{HW: .CPU} | del(.CPU)')
        rpi4_data=$(get_rpi_metrics|sed 's/\"CPU\"/\"HW\"/g' )
        data=$(echo "$data" |\
            jq --argjson HW "$rpi4_data" '.["CPU"] + $HW')
    fi
    data=$(echo "$data" |\
        jq --slurp --monochrome-output --indent 2)
    if [ $BASE_64 -eq 1 ]; then
        data=$(echo "$data"| base64)
    fi
    echo "$data"
}

## Collect data and exit
if [[ ($SERVICESTATUS == 1 || $SERVERSTATUS  == 1) && ${#FILENAME} -gt 3 ]]; then
    exporter_data > $FILENAME
    exit 0
else
    ## Prepare to run web server:
    ## include library and do preliminary check for web server
    source $(dirname "$0")/websrv.lib.sh    # Lib of functions to run netcat web server
    ## Preliminary check of launch conditions.
    ## check PID file existence and port availability
    if [ -f ${PID_FILE_DIR}/${APP_NAME}.pid ]; then
        if [[ $(cat ${PID_FILE_DIR}/${APP_NAME}.pid) != $$ ]]; then
            echo "$APP_NAME ERROR: PID file (${PID_FILE_DIR}/${APP_NAME}.pid) already exists. Therefore, the process is already running or was not terminated correctly." >&2
            exit 1
        fi
    else
        ## check if port is busy
        if nc -vz $SRV_ADDR $SRV_PORT > /dev/null 2>&1; then
            echo "$APP_NAME ERROR: Port $SRV_PORT on address $SRV_ADDR already in use" >&2
            exit 1
        fi
        ## save pid to file
        echo $$ > ${PID_FILE_DIR}/${APP_NAME}.pid || exit 1
    fi

    ## run server
    websrv_run
fi
