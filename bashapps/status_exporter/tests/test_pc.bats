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

@test "pc_check_requirement: docker - jq and awk unavailable" {
  command(){
    mock_command $*
  }
  export -f command
  run pc_check_requirement
  [ !$status ]
  [[ "$output" =~ "is not installed" ]]
  unset -f command
}

@test "pc_check_requirement: docker - jq available, awk unavailable" {
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

@test "pc_check_requirement: docker - jq and awk available" {
  command(){
    mock_command --mock "jq=0,awk=0" $*
  }
  export -f command
  run pc_check_requirement
  [ $status -eq 0 ]
  unset -f command
}

## TODO:
# pc_get_common_data
# pc_get_mem
# pc_get_cpu
# pc_get_storage
# pc_get_all