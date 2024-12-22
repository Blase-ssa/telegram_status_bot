#!/usr/bin/env bash
# This script allows me to run a web server that provides data for my bot (for monitoring servers)

# include port_work library
source $(dirname "$0")/websrv.lib.sh    # Lib of functions to run netcat web server
source $(dirname "$0")/pc.lib.sh        # Lib of functions to get local server metrics
source $(dirname "$0")/docker.lib.sh    # Lib of functions to get docker metrics

if [ -f .env.sh ]; then
    source $(dirname "$0")/.env.sh
else
    source $(dirname "$0")/default.env.sh
fi


