#!/usr/bin/env bash
# Set of functions for getting local server metrics in json format
# Require: awk, jq

pc_get_mem(){
    pc_mem_r=$(free -b | awk 'NR>1 {print "{\""$1"\":{\"Total\":\""$2"\",\"Used\":\""$3"\",\"Free\":\""$4"\",\"Shared\":\""$5"\",\"Cached\":\""$6"\",\"Available\":\""$7"\"}}"}' | jq | jq 'del(.["Swap:"].Shared, .["Swap:"].Cached, .["Swap:"].Available)')
    pc_swap_r=$(swapon --show --bytes| awk 'NR>1 {print "{\"Device\":\""$1"\",\"Type\":\""$2"\",\"Size\":\""$3"\",\"Used\":\""$4"\",\"Priority\":\""$5"\"}"}')
    return $(echo "$pc_mem_r" | jq --argjson details "$pc_swap_r" '.["Swap:"].Details = $details')
}

pc_get_cpu(){

}

pc_get_storage(){
    return $(df --exclude-type=tmpfs -h| awk 'NR>1 {print "{\"Filesystem\":\""$1"\",\"Size\":\""$2"\",\"Used\":\""$3"\",\"Avail\":\""$4"\",\"Use\":\""$5"\",\"Mountpoint\":\""$6"\"}"}' | jq -s .)
}