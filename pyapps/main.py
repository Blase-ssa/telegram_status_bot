#!/usr/bin/env python3
"""
    Telegram bot...
"""
# from common_imports import *
# from globals import *
from os import *
from common_imports import *
import pybot
import monitoring_srv
import threading

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

    # check server list
    global server_list
    globals.SERVER_LIST_FILENAME = get_config_filename("servers")
    server_list = ic(get_yaml_data("frontends"))
    if server_list is None:
        raise LookupError("No server configuration file provided")
    # set token for telegram bot
    globals.BOTTOKEN = get_secret("BOTTOKEN")

    # do sturtup precheck

    # run monitoring service
    # monitoring_main_thread = threading.Thread(
    #     target=monitoring_srv.start_monitoring_srv
    # )
    # monitoring_main_thread.start()

    # run telegram bot
    telegram_bot_main_thread = threading.Thread(target=pybot.pybot_main)
    telegram_bot_main_thread.start()
