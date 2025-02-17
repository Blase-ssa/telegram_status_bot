#!/usr/bin/env bats

load ../pc.lib.sh

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

@test "pc_check_requirement: jq and awk unavailable" {
  command(){
    mock_command $*
  }
  export -f command
  run pc_check_requirement
  [ !$status ]
  [[ "$output" =~ "is not installed" ]]
  unset -f command
}

@test "pc_check_requirement: jq available, awk unavailable" {
  command(){
    mock_command --mock "jq=0" $*
  }
  export -f command
  run pc_check_requirement
  [ $status -eq 1 ]
  echo "$output"
  [[ "awk - is not installed" =~ "$output" ]]
  unset -f command
}

@test "pc_check_requirement: jq and awk available" {
  command(){
    mock_command --mock "jq=0,awk=0" $*
  }
  export -f command
  run pc_check_requirement
  [ $status -eq 0 ]
  unset -f command
}

@test "pc_get_common_data: JSON Validation" {
  run $(pc_get_common_data| jq empty)
  [ $status -eq 0 ]
}

@test "pc_get_common_data: check hostname" {
  result=$(pc_get_common_data)
  [[ "$(echo $result|jq ".hostname"|sed 's/"//g')" == "$(hostname)" ]]
}

@test "pc_get_common_data: check variable existance" {
  result=$(pc_get_common_data)
  [[ "$(echo $result|jq 'has("name")')"         == "false" ]]
  [[ "$(echo $result|jq 'has("hostname")')"     == "true" ]]
  [[ "$(echo $result|jq 'has("uptime")')"       == "true" ]]
  [[ "$(echo $result|jq 'has("starttime")')"    == "true" ]]
  [[ "$(echo $result|jq 'has("users_count")')"  == "true" ]]
}

@test "pc_get_mem: JSON Validation" {
  run $(pc_get_common_data| jq empty)
  [ $status -eq 0 ]
}

@test "pc_get_mem: check variable existance" {
  result=$(pc_get_mem)
  [[ "$(echo $result|jq 'has("name")')" == "false" ]]

  [[ "$(echo $result|jq 'has("Mem")')"                  == "true" ]]
  [[ "$(echo $result|jq '.Mem'|jq 'has("Total")')"      == "true" ]]
  [[ "$(echo $result|jq '.Mem'|jq 'has("Used")')"       == "true" ]]
  [[ "$(echo $result|jq '.Mem'|jq 'has("Free")')"       == "true" ]]
  [[ "$(echo $result|jq '.Mem'|jq 'has("Shared")')"     == "true" ]]
  [[ "$(echo $result|jq '.Mem'|jq 'has("Cached")')"     == "true" ]]
  [[ "$(echo $result|jq '.Mem'|jq 'has("Available")')"  == "true" ]]

  [[ "$(echo $result|jq 'has("Swap")')"               == "true" ]]
  [[ "$(echo $result|jq '.Swap'|jq 'has("Total")')"   == "true" ]]
  [[ "$(echo $result|jq '.Swap'|jq 'has("Used")')"    == "true" ]]
  [[ "$(echo $result|jq '.Swap'|jq 'has("Free")')"    == "true" ]]
  [[ "$(echo $result|jq '.Swap'|jq 'has("Details")')" == "true" ]]
  
  run $(echo $result|jq ".Swap.Details[0]" | jq empty)
  [ $status -eq 0 ]
}

@test "pc_get_cpu: JSON Validation" {
run $(pc_get_cpu | jq empty)
  [ $status -eq 0 ]
}

@test "pc_get_cpu: check variable existance" {
  result=$(pc_get_cpu)
  [[ "$(echo $result|jq 'has("load_average")')" == "true" ]]
  [[ "$(echo $result|jq 'has("tasks")')"        == "true" ]]
  [[ "$(echo $result|jq 'has("cpu")')"          == "true" ]]
  [[ "$(echo $result|jq 'has("CPU_Count")')"    == "true" ]]
}

@test "pc_get_storage: JSON Validation" {
run $(pc_get_storage | jq empty)
  [ $status -eq 0 ]
}

@test "pc_get_all: JSON Validation" {
run $(pc_get_all | jq empty)
  [ $status -eq 0 ]
}

@test "pc_get_all: check main variable existance" {
  result=$(pc_get_all)
  [[ "$(echo $result|jq 'has("hostname")')"     == "true" ]]
  [[ "$(echo $result|jq 'has("server_time")')"  == "true" ]]
  [[ "$(echo $result|jq 'has("uptime")')"       == "true" ]]
  [[ "$(echo $result|jq 'has("starttime")')"    == "true" ]]
  [[ "$(echo $result|jq 'has("users_count")')"  == "true" ]]
  [[ "$(echo $result|jq 'has("RAM")')"          == "true" ]]
  [[ "$(echo $result|jq 'has("CPU")')"          == "true" ]]
  [[ "$(echo $result|jq 'has("Storages")')"     == "true" ]]
}

@test "pc_get_all: check some sub variable existance" {
  result=$(pc_get_all)
  [[ "$(echo $result|jq '.RAM'|jq 'has("Mem")')"          == "true" ]]
  [[ "$(echo $result|jq '.RAM'|jq 'has("Swap")')"         == "true" ]]
  [[ "$(echo $result|jq '.CPU'|jq 'has("load_average")')" == "true" ]]
  [[ "$(echo $result|jq '.CPU'|jq 'has("tasks")')"        == "true" ]]
}