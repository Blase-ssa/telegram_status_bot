#!/usr/bin/env bash
# Set of functions for getting docker metrics in json format
# Require: Docker 

__DOCKER_LIB__=true

docker_check_requirement(){
    ### check if the Docker installed in the system
    command -v docker > /dev/null 2>&1 && return 0 || return 1
}

docker_get_containers(){
    ### get list of container(s) and they're status in json format
    docker ps -a --format json
}

docker_get_resource_usage(){
    ### get container(s) resource usage statistics in json format
    docker stats --format json --no-stream
}
