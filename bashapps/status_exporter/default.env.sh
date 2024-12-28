## server port
SRV_PORT=8001
## server interface
SRV_ADDR=127.0.0.1
## timeout waiting for connection to nc server in seconds
## Set to 0 to disable timeout and enable "stable algorithm"
SRV_TIMEOUT=60

## how often will the server status information be updated
RENEW_TIMEOUT=360

## 0 - disable base64; 1 enable base64 encryption
BASE_64=0

## app name 
## If for some reason you need to run more than 1 instance of the program,
## just change the name here.
APP_NAME="statusexporter"

## Change this path if you don't want to install the application as a service.
## Example:
# PID_FILE_DIR="/opt/status_exporter"
## or if you wat to use current directory
# PID_FILE_DIR="."
## this option is recommended for running as a service
PID_FILE_DIR="/var/run/status_exporter/"