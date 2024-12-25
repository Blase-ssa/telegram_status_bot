#!/usr/bin/env bash
# Set of functions for getting docker metrics in json format
# Require: Docker 

docker_check_requirement(){
    ### check if the Docker installed in the system
    if command -v docker > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

docker_get_containers(){
    ### get list of container(s) and they're status in json format
    docker ps -a --format json
}

docker_get_resource_usage(){
    ### get container(s) resource usage statistics in json format
    docker stats -a --format json --no-stream
}
