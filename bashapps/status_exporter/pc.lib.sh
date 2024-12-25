#!/usr/bin/env bash
# Set of functions for getting local server metrics in json format
# Require: awk, jq

pc_get_common_data(){
    return $(echo "{\"hostname\":\"$(hostname)\",\"uptime\":\"$(uptime -p)\",\"starttime\":\"$(uptime -s)\",userscount:$(who |wc -l)}")
}

pc_get_mem(){
    pc_mem_r=$(free -b | awk 'NR>1 {print "{\""$1"\":{\"Total\":\""$2"\",\"Used\":\""$3"\",\"Free\":\""$4"\",\"Shared\":\""$5"\",\"Cached\":\""$6"\",\"Available\":\""$7"\"}}"}' | jq | jq 'del(.["Swap:"].Shared, .["Swap:"].Cached, .["Swap:"].Available)')
    pc_swap_r=$(swapon --show --bytes| awk 'NR>1 {print "{\"Device\":\""$1"\",\"Type\":\""$2"\",\"Size\":\""$3"\",\"Used\":\""$4"\",\"Priority\":\""$5"\"}"}')
    return $(echo "$pc_mem_r" | jq --argjson details "$pc_swap_r" '.["Swap:"].Details = $details')
}

pc_get_cpu(){
    top -bn1 |head -n 3| awk '
        BEGIN {
            print "{"
        }
        NR==1 {
            split($0, a, ",")
            print "\"load_average\": \"" a[4] "\""
            print "},"
        }
        NR==2 {
            print "\"tasks\": {"
            print "\"total\": " $2 ","
            print "\"running\": " $4 ","
            print "\"sleeping\": " $6 ","
            print "\"stopped\": " $8 ","
            print "\"zombie\": " $10
            print "},"
        }
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
            print "},"
        }
        END {
            print "}"
        }'
}

pc_get_storage(){
    return $(df --exclude-type=tmpfs -h| awk 'NR>1 {print "{\"Filesystem\":\""$1"\",\"Size\":\""$2"\",\"Used\":\""$3"\",\"Avail\":\""$4"\",\"Use\":\""$5"\",\"Mountpoint\":\""$6"\"}"}' | jq -s .)
}

pc_get_all(){

}