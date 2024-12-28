# JSON Status Exporter
## Purpose
This set of scripts is designed to provide certain metrics from my servers to my telegram bot. These metrics can also be collected and stored in a DB (I intend to use InfluxDB for this purpose) for further processing and study (in Grafana in my case).

## Why bash?
I didn't want to write this code in Python, because Python consumes a lot of resources (and I am extremely limited in them because I use a free service), and I also don't want to install Python directly on the server. I would like to use Golang, but I didn't want to spend a lot of time (I thought I would do everything on bash in a day, but I spent 4 days on it (1 full day to solve some JSON formatting problem, and 3 days on average 2 hours a day on other problems.))

## Warning
* `netcat` is not intended to be used as a web server all the time and may have vulnerabilities that could allow an attacker to gain access to your server. So make sure that no one other than the necessary applications has access to the port on which `netcat` is listening.
* I also do not exclude the possibility that my code may not be stable, so if you run it, you do so at your own risk.

## Installation and running
### General
* create directory `/opt/status_exporter/`
* copy all files to this directory
    ```bash
    cp * /opt/status_exporter/
    ```
* copy `default.env.sh` and rename copy to `.env.sh`
* edit `.env.sh` to specify your preferences

### systemd
* create user `sexport` and add him in group `docker` if you have docker installed on your server
    ```bash
    sudo useradd -r -s /usr/sbin/nologin sexport
    sudo usermod -aG docker sexport
    ```
* give permissions to the user to have access to app dir
    ```bash
        chown -R sexport /opt/status_exporter
        chmod -R u+rx /opt/status_exporter
    ```
* set up autostart 
    * copy or move `statusexporter.service` to `/etc/systemd/system/`
        ```bash
        sudo cp statusexporter.service /etc/systemd/system/
        ```
    * Reload the systemd configuration, enable service autostart and start the service by running the following commands:
        ```bash
        sudo systemctl daemon-reload
        sudo systemctl enable statusexporter.service
        sudo systemctl start statusexporter.service
        ```
* to stop service use
    ```bash
    sudo systemctl stop statusexporter.service
    ```

### non service mode
* edit `.env.sh` and set PID_FILE_DIR to be equal `"."`
* start with command:
    ```bash
    nohup /opt/status_exporter/startexporter.sh &
    ```
* stop with command:
    ```bash
    /opt/status_exporter/stopexporter.sh
    ```

## ToDo:
- add more descriptions in functions
- create install script
- maybe: create whiptail based interface to control script (install/uninstall, run, etc)
- add network metrics support