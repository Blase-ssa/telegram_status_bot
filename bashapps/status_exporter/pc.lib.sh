#!/usr/bin/env bash
# Set of functions for getting local server metrics in json format
# Require: awk, jq

pc_check_requirement(){
    ### check system requirements
    if ! command -v jq > /dev/null 2>&1; then
        echo "jq - is not installed"
        return 1
    fi
    if ! command -v awk > /dev/null 2>&1; then
        echo "awk - is not installed"
        return 1
    fi
    return 0
}

pc_get_common_data(){
    ## get common server data, like: hostname, uptime, count of currently logged users in json format
    echo "{\"hostname\":\"$(hostname)\",\"server_time\":\"$(date +%s)\",\"uptime\":\"$(uptime -p)\",\"starttime\":\"$(uptime -s) $(date +"%z")\",\"users_count\":\"$(who |wc -l)\"}"
}

pc_get_mem(){
    ## get memory utilization including swap in json format
    pc_mem_r=$(free -b |\
        free -b |\
        awk 'BEGIN {print "{"}; NR>1 {if (NR > 2) {print ","} else {print ""}; printf "\""$1"\":{\"Total\":\""$2"\",\"Used\":\""$3"\",\"Free\":\""$4"\",\"Shared\":\""$5"\",\"Cached\":\""$6"\",\"Available\":\""$7"\"}"}; END {print "}"}' |\
        sed "s/:\":/\":/g" |\
        jq 'del(.["Swap"].Shared, .["Swap"].Cached, .["Swap"].Available)')

    pc_swap_r=$(swapon --show --bytes|\
        awk 'NR>1 {print "{\"Device\":\""$1"\",\"Type\":\""$2"\",\"Size\":\""$3"\",\"Used\":\""$4"\",\"Priority\":\""$5"\"}"}'|\
        jq --slurp --compact-output)

    ## return:
    echo "$pc_mem_r" | jq --argjson details "$pc_swap_r" '.["Swap"].Details = $details'
}

pc_get_cpu(){
    ## get CPU resource usage statistics in json format
    top_raw=$(top -bn1 |head -n 3) # get data to parse
    cpu_count=$(cat /proc/cpuinfo |grep -c processor) # Load average useful if upu know count of cpu's
    load_average=$(echo "$top_raw"|\
        head -n 1|\
        grep -Po 'load average: \K.*$'|\
        awk '{split($0, a, ","); print "\"load_average\": {\"1m\": \""a[1]"\", \"5m\": \""a[2]"\", \"15m\": \""a[3]"\"}"}'|\
        sed 's/ //g')

    tasks=$(echo "$top_raw" | awk '
        NR==2 {
            print "\"tasks\": {"
            print "\"total\": " $2 ","
            print "\"running\": " $4 ","
            print "\"sleeping\": " $6 ","
            print "\"stopped\": " $8 ","
            print "\"zombie\": " $10
            print "}"
        }')
    cpu=$(echo "$top_raw" | awk '
        NR==3 {
            print "\"cpu\": {"
            print "\"us\": " $2 ","
            print "\"sy\": " $4 ","
            print "\"ni\": " $6 ","
            print "\"id\": " $8 ","
            print "\"wa\": " $10 ","
            print "\"hi\": " $12 ","
            print "\"si\": " $14 ","
            print "\"st\": " $16
            print "}"
        }')
    
    ## return:
    echo "{$load_average,$tasks,$cpu}"|jq --argjson cpuc "$cpu_count" '.CPU_Count = $cpuc'
}

pc_get_storage(){
    ## get storage utilization in json format
    df --exclude-type=tmpfs -h|sed 's|\\|\\\\|g' | awk 'NR>1 {print "{\"Filesystem\":\""$1"\",\"Size\":\""$2"\",\"Used\":\""$3"\",\"Avail\":\""$4"\",\"Use\":\""$5"\",\"Mountpoint\":\""$6"\"}"}' | jq -s .
}

pc_get_all(){
    ## get all data in one function
    echo "$(pc_get_common_data)" |\
        jq --argjson mem "$(pc_get_mem)" '.RAM = $mem'|\
        jq --argjson cpu "$(pc_get_cpu)" '.CPU = $cpu'|\
        jq --argjson stor "$(pc_get_storage)" '.Storages = $stor'
}