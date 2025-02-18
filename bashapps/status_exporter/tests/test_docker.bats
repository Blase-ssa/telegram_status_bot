#!/usr/bin/env bats

load ../docker.lib.sh
load ./mock_functions.lib.sh

## TESTS
@test "docker_check_requirement: docker - unavailable" {
  command(){
    return 1
  }
  export -f command
  [ !docker_check_requirement ]
  unset -f command
}

@test "docker_check_requirement: docker - available" {
  command(){
    return 0
  }
  export -f command
  [ docker_check_requirement ]
  unset -f command
}

@test "docker_get_containers: empty response" {
  docker() {
    mock_docker_ps_empty "$@"
  }
  export -f docker
  run docker_get_containers
  [ $status -eq 0 ]
  [ -z "$output" ]
  unset -f docker
}

JSON_RESULT_4_MOCK_DOCKER='{"Command":"\"/docker-entrypoint.…\"","CreatedAt":"2025-01-24 16:14:14 +0000 UTC","ID":"0ffd8cd8a1c0","Image":"nginx","Labels":"maintainer=NGINX Docker Maintainers \u003cdocker-maint@nginx.com\u003e","LocalVolumes":"0","Mounts":"","Names":"sweet_nash","Networks":"bridge","Ports":"80/tcp","RunningFor":"4 minutes ago","Size":"0B","State":"running","Status":"Up 4 minutes"}'
@test "docker_get_containers: empty response (nginx)" {
  docker() {
    mock_docker_ps_nginx "$@"
  }
  export -f docker
  result="$(docker_get_containers)"
  [[ "$result" == "$JSON_RESULT_4_MOCK_DOCKER" ]]
  unset
  unset -f docker
}

@test "docker_get_resource_usage: empty response" {
  docker() {
    return 0
  }
  export -f docker
  run docker_get_resource_usage
  [ $status -eq 0 ]
  [ -z "$output" ]
  unset -f docker
}

JSON_RESULT_4_MOCK_DOCKER_STATS='{"BlockIO":"36.7MB / 4.1kB","CPUPerc":"0.00%","Container":"0ffd8cd8a1c0","ID":"0ffd8cd8a1c0","MemPerc":"0.17%","MemUsage":"13.4MiB / 7.743GiB","Name":"sweet_nash","NetIO":"1.32kB / 0B","PIDs":"3"}'
@test "docker_get_resource_usage: nginx" {
  docker() {
    echo $JSON_RESULT_4_MOCK_DOCKER_STATS
    return 0
  }
  export -f docker
  result="$(docker_get_resource_usage)"
  [[ "$result" == "$JSON_RESULT_4_MOCK_DOCKER_STATS" ]]
  unset -f docker
}
