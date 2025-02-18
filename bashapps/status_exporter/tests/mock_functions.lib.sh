#!/usr/bin/env bash

## docker
mock_docker_ps_empty(){
  if [ "$1" == "ps" ]; then
    for arg in "$@"; do 
      if [ "$arg" == "json" ]; then 
        return 0
      fi 
    done
    
    echo "CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES"
    return 0
  else
    echo "Unknown command"
    return 1
  fi
}

mock_docker_ps_nginx(){
  if [ "$1" == "ps" ]; then
    for arg in "$@"; do 
      if [ "$arg" == "json" ]; then
        echo "$JSON_RESULT_4_MOCK_DOCKER"
        return 0
      fi 
    done

    echo "CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES
0ffd8cd8a1c0   nginx     "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes   80/tcp    sweet_nash"
    return 0
  else
    echo "Unknown command"
    return 1
  fi
}

## command
mock_command(){
  jq_s=1
  awk_s=1
  while [[ $# -gt 0 ]]; do
    if [ "$1" == "--mock" ]; then
      jq_s=$(echo $2| grep -Po "jq=\K\d" || $jq_s)
      awk_s=$(echo $2| grep -Po "awk=\K\d" || $awk_s)
      shift 2
    fi
    if [ "$1" == "-v" ]; then
      if [ "$2" == "jq" ] && [ $jq_s ]; then
        echo "/usr/bin/jq"
        return $jq_s
      fi
      if [ "$2" == "awk" ] && [ $awk_s ]; then
        echo "/usr/bin/awk"
        return $awk_s
      fi
      shift 2
    else
      shift 1
    fi
  done
  return 1
}
