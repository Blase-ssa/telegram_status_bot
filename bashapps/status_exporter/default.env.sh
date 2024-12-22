# server port
SRV_PORT=8001
## timeout waiting for connection to nc server in seconds
## Set to 0 to disable timeout and enable "stable algorithm"
SRV_TIMEOUT=60
# http header
SRV_HEADER="HTTP/1.1 200 Everything Is Just Fine
Server: Stat Exporter
Content-Type: text/html; charset=UTF-8"

BASE_64=0 # 0 - disable base64; 1 enable base64 encryption
