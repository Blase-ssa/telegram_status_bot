#!/usr/bin/env bash
# Set of functions for getting Raspberry Pi 4 in Argone case specific metrics in json format

rpi4_check_requirement(){
  ### check system requirements
  if !(-e /etc/argononed.conf); then
    echo "Argon configuration is not found"
    return 1
  fi
  if !(-e /bin/vcgencmd); then
    if command -v vcgencmd > /dev/null 2>&1; then
      echo "vcgencmd - found but not in /bin/; correct location $(which vcgencmd)"
    else
      echo "vcgencmd - not found"
    fi
    return 1
  fi
  return 0
}

rpi4_get_fun_speed(){
  local fan_conf=`echo -e "0=0\n$(cat /etc/argononed.conf)"`
  local temp_rate=$(echo "${fan_conf}"|grep -Po '^\d+'|awk "\$0 <= $(( $(rpi4_get_cpu_temp) / 1000 ))"|tail -n1)
  echo "${fan_conf}"|grep -Po "^${temp_rate}=\K\d+\$"
}

rpi4_get_cpu_temp(){
  cat /sys/class/thermal/thermal_zone0/temp
}

get_rpi_metrics(){
  echo "\"CPU\": {
    \"gpu_temperature\": \"$(/bin/vcgencmd measure_temp| grep -Po '\d+\.\d+')\",
    \"clock_speed\": \"$(/bin/vcgencmd measure_clock arm |grep -Po '=\K\d+$')\",
    \"volts\": \"$(/bin/vcgencmd measure_volts|grep -Po '=\K\d+\.\d+')\",
    \"temperature\": \"$(rpi4_get_cpu_temp)\",
    \"fun_speed\": \"$(rpi4_get_fun_speed)\"
  }"
}