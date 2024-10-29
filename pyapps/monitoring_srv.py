import time
from flask import Flask
import threading
import signal

from common_imports import *
import globals

monitoring_srv = Flask(__name__)
json_full_status = ""
json_short_status = ""
str_short_status = ""
str_full_status = ""


shutdown_event = threading.Event()


def monitoring_service():
    global str_short_status
    global json_full_status
    global json_short_status
    global str_short_status
    global str_full_status
    cycle_sleep_time = globals.GET_STATUS_TIME * 1_000_000_000
    cycle_start_time = time.time_ns()
    while not shutdown_event.is_set():
        if time.time_ns() - cycle_start_time >= cycle_sleep_time:
            cycle_start_time = time.time_ns()
            json_full_status = time.ctime()
            json_short_status = time.ctime()
            str_short_status = time.ctime()
            str_full_status = time.ctime()
        else:
            time.sleep(1)  # sleep 1 second


@monitoring_srv.route("/")
def index():
    return f"<pre>{str_short_status}</pre>"


def start_monitoring_srv():
    monitoring_service_thread = threading.Thread(target=monitoring_service)
    monitoring_service_thread.start()
    monitoring_srv.run(host="0.0.0.0", port=5000)


def handle_signal(signal, frame):
    shutdown_event.set()
    monitoring_service.join()
    print("Программа завершена.")


if __name__ == "__main__":
    start_monitoring_srv()
