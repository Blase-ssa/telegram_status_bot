#!/usr/bin/env python3

from common_imports import *
import globals

import os
import re
import yaml


def get_config_filename(name: str, location: str = globals.CONFIGDIR) -> str:
    """
    function to search for a server list file name.
    """
    regex = re.compile(f"{name}.ya*ml", re.IGNORECASE)
    files = os.listdir(location)
    for file in files:
        if regex.match(file):
            return f"{location}/{file}"
    # raise LookupError("no configuration file provided")
    return None


def get_yaml_data(key: str, YAML_file: str = None):
    """
    Read and return list of data from file
    """
    ic(globals.SERVER_LIST_FILENAME)
    if YAML_file is None:
        YAML_file = globals.SERVER_LIST_FILENAME
    if os.path.exists(YAML_file):
        ic(f'File "{YAML_file}" exists')
    else:
        ic(f'File "{YAML_file}" does not exist')
        return None
    # open YAML file to read
    ic("open file")
    with open(YAML_file, "r") as file:
        # data = yaml.load(file, Loader=yaml.FullLoader) #TODO: Check, there should be a more efficient loader for loading YAML, so as not to use a loop to search for a block later.
        ic("read file")
        # ic(file.read())
        data = yaml.safe_load(file)
    # exit if there is no data in data (file is empty)
    # ic(data)
    if not data:
        return None

    for block in data:
        if str(list(block.keys())[0]) == key:
            # return(list(block))
            return block
    # extit if block was not found (file not empty, but blok was not found)
    ic(f'Key "{key}" does not exist')
    return None


def search_yaml_data(key: str, value: str, YAML_file: str = None):
    """
    This function search in YAML_file file, key with value.
    and return dictionary or None, if data not exist
    """
    if os.path.exists(YAML_file):
        ic(f'File "{YAML_file}" exists')
    else:
        ic(f'File "{YAML_file}" does not exist')
        return None
    # open YAML file to read
    with open(YAML_file, "r") as file:
        ic(f"read {YAML_file} file to search for {key}={value}")
        data = yaml.safe_load(file)
    # exit if there is no data in data (file is empty)
    # ic(data)
    if not data:
        return None

    for block in data:
        ic(block)
        if key in block and str(block[key]) == str(value):
            return block
    # extit if block was not found (file not empty, but blok was not found)
    ic(f'Pair "{key}={value}" does not exist')
    return None


def get_secret(secret) -> str:
    """
    Function check if environmen variable specified, and return it's value
    if not, then it will search for same variable in yaml.
    but it should be in .env file.
    """
    ic(secret)
    l_secret = os.environ.get(secret)
    if l_secret is None:
        l_secret = get_yaml_data(secret)  # extract value from dict_value object
        if l_secret is None or l_secret[secret] is None:
            return None
        return str(l_secret[secret])
    return l_secret


def get_permissions(user_id):  # -> list:
    """
    Function returns a list with user permissions, or None if user was not found in a list.

    Since the list of users who will use this bot is extremely small (only 5 people),
    there is no point in storing this list in the database.
    """
    ic(globals.USER_DB)
    rigts = ic(search_yaml_data("id", user_id, globals.USER_DB))
    return None if not rigts else rigts


def get_access(user_id, command) -> bool:
    permissions = ic(get_permissions(user_id))
    if permissions is None:
        return False
    if command not in permissions["rights"]:
        return False
    return bool(permissions["rights"][command])


def get_help(user_id) -> str:
    data = search_yaml_data("id", user_id, globals.USER_DB)
    ic(data)
    if data is None:
        return globals.DEFAULT_HELP
    if data.get("help") is None:
        return globals.DEFAULT_HELP
    return data["help"]
