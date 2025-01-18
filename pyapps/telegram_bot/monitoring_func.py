import globals
from core_functions import *
import socket
import subprocess
import json
import emoji
import requests

def get_servers_status_4bot(server_list: dict) -> str:
    """
    This function returns the status of servers in human-readable format.
    """
    respond_msg = ""
    main_key = list(server_list.keys())[0]
    for srv in server_list[main_key]:
        ic(srv["name"])
        # check short name if it's exist
        if "shortname" in srv:
            srv_name = srv["shortname"]
        else:
            srv_name = srv["name"]
        # check if the server disabled or enabled (default is enabled)
        if "availability" in srv and srv["availability"] == False:
            respond_msg = (
                f"{respond_msg}\n"
                f"{emoji.circle_red} {srv_name} (DNS name not available) {emoji.arrow_right} Disabled"
            )
            continue  # next loop if disabled

        # check DNS registration / check IP address AND ping port on server
        IP_ADDR = get_ip_address(srv["name"])
        if IP_ADDR is None:
            respond_msg = (
                f"{respond_msg}\n"
                f"{emoji.cross_red} {srv_name} (DNS name not available) {emoji.arrow_right} Unreachable"
            )
        else:
            # проверка если порт определён в конфиге сервера
            if "statusport" in srv:
                status = ping_srv(IP_ADDR, int(srv["statusport"]))
            else:
                # if not then use default port
                status = ping_srv(IP_ADDR)

            if status == "Online":
                respond_msg = (
                    f"{respond_msg}\n"
                    f"{emoji.checkmark_greenbg} {srv_name} ({IP_ADDR}) {emoji.arrow_right} {status}"
                )
            else:
                respond_msg = (
                    f"{respond_msg}\n"
                    f"{emoji.cross_red} {srv_name} ({IP_ADDR}) {emoji.arrow_right} {status}"
                )
    return respond_msg

def collect_server_status_row(server_addr, exporter_port) -> list:
    request_handler = requests.get(
        f"{server_addr}:{exporter_port}\status\metrics",
        allow_redirects=True,
        timeout=30,
        headers={
            "PRIVATE-TOKEN": token,
            "Accept": "application/json",
            "encoding": "utf-8",
        },
    )
    if request_handler.status_code != 200:
        raise ConnectionError
    return request_handler.content

def ping_srv(srv: str, port: int = 22):
    respond_msg = "Dead"
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(5)  # Устанавливаем таймаут на 5 секунд
        result = sock.connect_ex((srv, port))
        if result == 0:
            respond_msg = "Online"
        else:
            respond_msg = "Offline"
    return respond_msg


def get_ip_address(domain_name):
    try:
        ip_address = socket.gethostbyname(domain_name)
        ic(ip_address)
        return ip_address
    except socket.gaierror:
        return None


def start_monitoring_service():
    """
    This function is a service to collect monitoring data
    """
    get_yaml_data("frontend")
    ic(get_servers_status_4bot(get_yaml_data("frontend")))
    ic(get_servers_status_4bot(get_yaml_data("backend")))


def start_monitoring_server():
    """
    This is a server to publish monitoring data
    """
    ic(get_docker_status())
    pass


def get_docker_status() -> list:
    result: list = []
    # get list of containers
    result.append(
        json.dump(
            subprocess.run(
                ["docker ps --format json --no-trunc --all"],
                capture_output=True,
                text=True,
                timeout=5,
            )
        )
    )

    # get container(s) resource usage statistics
    # result.append(json.loads(subprocess.run(["docker stats --format json --no-stream --no-trunc"], capture_output=True, text=True, timeout=5)))
    return result


def monitoring_main():
    globals.SERVER_LIST_FILENAME = get_config_filename(
        globals.SERVER_LIST_FILENAME_PROTOTYPE
    )
    start_monitoring_service()
    start_monitoring_server()


if __name__ == "__main__":
    # set globals
    if os.environ.get("CONFIGDIR") != None:
        # rewrite default path
        globals.CONFIGDIR = os.environ.get("CONFIGDIR")
    if os.environ.get("SERVER_LIST_FILENAME_PROTOTYPE") != None:
        # rewrite default filename prototype
        globals.SERVER_LIST_FILENAME_PROTOTYPE = os.environ.get(
            "SERVER_LIST_FILENAME_PROTOTYPE"
        )
    monitoring_main()
