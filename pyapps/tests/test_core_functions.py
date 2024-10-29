#!/usr/bin/env python3
"""
    Unit tests for core_functions
    This unit test writen with help of Copilot
"""
import unittest
from unittest.mock import patch  # , MagicMock
import os

# import re
# import yaml
import globals
from pathlib import Path
from common_imports import *
from core_functions import *

dummy_test_filename_0 = "./tests/dummy_0.yaml"  # not exist
dummy_test_filename_d = "./tests/dummy_d.yaml"  # should exist or be crteated
dummy_test_filename_e = (
    "./tests/dummy_e.yaml"  # should exist or be crteated and have no data inside
)
dummy_test_filename_p = "./tests/dummy_p.yaml"  # test file to test user operations

# Prepare test file
if not os.path.exists(dummy_test_filename_d):
    dummy_test_file = Path(dummy_test_filename_d)
    dummy_test_file.touch()  # Создаем пустой файл
    # test data
    yaml_data = (
        f"---\n"
        f"- MY_SECRET: 'yaml_secret_value'\n"
        f"- key1:\n"
        f"  - value1\n"
        f"  - value2\n"
        f"- key2:\n"
        f"  - value3\n"
        f"  - value4\n"
        f"...\n"
    )
    # write test data in to file
    with open(dummy_test_filename_d, "w") as file:
        file.writelines(yaml_data)

if not os.path.exists(dummy_test_filename_e):
    dummy_test_file_e = Path(dummy_test_filename_e)
    dummy_test_file_e.touch()  # Создаем пустой файл

# Prepare test file
if not os.path.exists(dummy_test_filename_p):
    dummy_test_file = Path(dummy_test_filename_p)
    dummy_test_file.touch()  # Создаем пустой файл
    # test data
    yaml_data = (
        f"---\n"
        f"- id: '123456789'\n"
        f'  name: "test9"\n'
        f'  username: "@test9"\n'
        f"  rights:\n"
        f"    status: true\n"
        f"    fullstatus: true\n"
        f"    search: false\n"
        f"    chat: false\n"
        f"    help: true\n"
        f'  help: "Stub for help\\n"\n\n\n'
        f'- id: "12345678"\n'
        f'  name: "test8"\n'
        f'  username: "@test8"\n'
        f"  rights:\n"
        f"    status: true\n"
        f"    fullstatus: true\n"
        f"- id: 87654321\n"
        f'  name: "test81"\n'
        f'  username: "@test81"\n'
        f"  rights:\n"
        f"    fullstatus: true\n"
        f"...\n"
    )
    # write test data in to file
    with open(dummy_test_filename_p, "w") as file:
        file.writelines(yaml_data)


class TestGetServerListFilename(unittest.TestCase):
    @patch("os.listdir")
    def test_get_config_filename(self, mock_listdir):
        # Задаем список файлов, который будет возвращен os.listdir()
        mock_listdir.return_value = [
            "servers.yaml",
            "config.yml",
            "servers.YAML",
            "data.json",
        ]

        # Ожидаемое значение
        expected_filename = f"{globals.CONFIGDIR}/servers.yaml"

        # Вызов функции и проверка результата
        result = get_config_filename(globals.SERVER_LIST_FILENAME_PROTOTYPE)
        self.assertEqual(result, expected_filename)

    @patch("os.listdir")
    def test_get_config_filename_short_extension(self, mock_listdir):
        # Задаем список файлов, который будет возвращен os.listdir()
        mock_listdir.return_value = ["servers.yml", "servers.YAML", "data.json"]

        # Ожидаемое значение (первый в списке)
        expected_filename = f"{globals.CONFIGDIR}/servers.yml"

        # Вызов функции и проверка результата
        result = get_config_filename(globals.SERVER_LIST_FILENAME_PROTOTYPE)
        self.assertEqual(result, expected_filename)

    @patch("os.listdir")
    def test_get_config_filename_case_insensitive(self, mock_listdir):
        # Задаем список файлов, который будет возвращен os.listdir()
        mock_listdir.return_value = ["SERVERS.YAML", "config.yml", "data.json"]

        # Ожидаемое значение
        expected_filename = f"{globals.CONFIGDIR}/SERVERS.YAML"

        # Вызов функции и проверка результата
        result = get_config_filename(globals.SERVER_LIST_FILENAME_PROTOTYPE)
        self.assertEqual(result, expected_filename)

    @patch("os.listdir")
    def test_get_config_filename_no_match(self, mock_listdir):
        # Задаем список файлов, который будет возвращен os.listdir()
        mock_listdir.return_value = ["config.yml", "data.json"]

        # Ожидаемое значение
        expected_filename = None

        # Вызов функции и проверка результата
        result = get_config_filename(globals.SERVER_LIST_FILENAME_PROTOTYPE)
        self.assertEqual(result, expected_filename)


class TestGetYamlData(unittest.TestCase):

    def test_get_yaml_data_file_not_exist(self):
        result = get_yaml_data("key1", dummy_test_filename_0)
        self.assertEqual(result, None)

    def test_get_yaml_data_global_var_file_not_exits(self):
        globals.SERVER_LIST_FILENAME = dummy_test_filename_0
        result = get_yaml_data("key1")
        self.assertIsNone(result)

    def test_get_yaml_data_key_exists(self):
        expected_result = {"key1": ["value1", "value2"]}
        result = get_yaml_data("key1", dummy_test_filename_d)
        self.assertEqual(result, expected_result)

    def test_get_yaml_data_key_not_exists(self):
        result = get_yaml_data("key3", dummy_test_filename_d)
        self.assertIsNone(result)

    def test_get_yaml_data_empty_file(self):
        result = get_yaml_data("key1", dummy_test_filename_e)
        self.assertIsNone(result)


class TestGetSecret(unittest.TestCase):

    @patch("os.environ.get")
    def test_get_secret_from_env(self, mock_environ_get):
        # Настраиваем mock для os.environ.get
        mock_environ_get.return_value = "env_secret_value"
        result = get_secret("MY_SECRET")
        self.assertEqual(result, "env_secret_value")
        mock_environ_get.assert_called_once_with("MY_SECRET")

    @patch("os.environ.get", return_value=None)
    def test_get_secret_from_yaml(self, mock_environ_get):
        globals.SERVER_LIST_FILENAME = dummy_test_filename_d
        result = get_secret("MY_SECRET")
        self.assertEqual(result, "yaml_secret_value")
        mock_environ_get.assert_called_once_with("MY_SECRET")

    @patch("os.environ.get", return_value=None)
    def test_get_secret_file_not_found(self, mock_environ_get):
        globals.SERVER_LIST_FILENAME = dummy_test_filename_0
        result = get_secret("MY_SECRET")
        self.assertIsNone(result)
        mock_environ_get.assert_called_once_with("MY_SECRET")

    @patch("os.environ.get", return_value=None)
    def test_get_secret_not_found(self, mock_environ_get):
        globals.SERVER_LIST_FILENAME = dummy_test_filename_e
        result = get_secret("MY_SECRET")
        self.assertIsNone(result)
        mock_environ_get.assert_called_once_with("MY_SECRET")


class TestGetPermissions(unittest.TestCase):

    def test_get_permissions_file_not_found(self):
        globals.USER_DB = dummy_test_filename_0
        result = get_permissions("12345678")
        self.assertIsNone(result)

    def test_get_permissions_empty_file(self):
        globals.USER_DB = dummy_test_filename_e
        result = get_permissions("12345678")
        self.assertIsNone(result)

    def test_get_permissions_not_found(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_permissions("123456")
        ic(result)
        expected_result = None
        self.assertEqual(result, expected_result)

    def test_get_permissions_found(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_permissions("12345678")
        ic(result)
        expected_result = {
            "id": "12345678",
            "name": "test8",
            "rights": {"fullstatus": True, "status": True},
            "username": "@test8",
        }
        self.assertEqual(result, expected_result)


class TestGetAccess(unittest.TestCase):
    def test_get_access_no_quotes(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_access("87654321", "fullstatus")
        self.assertEqual(result, True)

    def test_get_access_single_quotes(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_access("12345678", "fullstatus")
        self.assertEqual(result, True)

    def test_get_access_double_quotes(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_access("123456789", "fullstatus")
        self.assertEqual(result, True)

    def test_get_access_false(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_access("123456789", "search")
        self.assertEqual(result, False)

    def test_get_access_command_not_exist(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_access("12345678", "something")
        self.assertEqual(result, False)


class TestGetHelp(unittest.TestCase):

    def test_get_help_not_in_config(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_help("12345678")
        self.assertEqual(result, globals.DEFAULT_HELP)

    def test_get_help_in_config(self):
        globals.USER_DB = dummy_test_filename_p
        result = get_help("123456789")
        self.assertEqual(result, "Stub for help\n")
