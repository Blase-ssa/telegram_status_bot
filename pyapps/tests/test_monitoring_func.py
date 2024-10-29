#!/usr/bin/env python3
import pytest
from monitoring_func import *
import socket
from threading import Thread

import unittest
from unittest.mock import patch, Mock
import json
import subprocess

import globals

# from core_functions import *
# ic(get_yaml_data("frontends", "servers.yml"))

# listen_port_status=True
# openport=8090
# def listen_port():
#     HOST = 'localhost'
#     PORT = openport

#     with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
#         server_socket.bind((HOST, PORT))
#         server_socket.listen()
#         while listen_port_status:
#             conn, addr = server_socket.accept()
#             ic(listen_port_status)
#             with conn:
#                 conn.sendall(b"status='OK'")


GET_IP_ADDRESS_TEST_DATA = [("localhost", "127.0.0.1"), ("somehost.local", None)]


@pytest.mark.parametrize("server, result", GET_IP_ADDRESS_TEST_DATA)
def test_get_ip_address(server, result):
    assert get_ip_address(server) == result


PING_SRV_TEST_DATA = [("example.com", 80, "Online"), ("localhost", 81, "Offline")]


@pytest.mark.parametrize("server, port, result", PING_SRV_TEST_DATA)
def test_ping_srv(server, port, result):
    assert ping_srv(server, port) == result


GET_SERVER_STATUS_TEST_DATA = [
    (
        {
            "frontends": [
                {
                    "name": "localhost",
                }
            ]
        },
        f"\n\u274c localhost (127.0.0.1) \u27a1\ufe0f Offline",
    ),
    (
        {
            "frontends": [
                {
                    "name": "localhost",
                },
                {
                    "name": "127.0.0.1",
                },
                {
                    "name": "localhost",
                },
            ]
        },
        f"\n\u274c localhost (127.0.0.1) \u27a1\ufe0f Offline"
        f"\n\u274c 127.0.0.1 (127.0.0.1) \u27a1\ufe0f Offline"
        f"\n\u274c localhost (127.0.0.1) \u27a1\ufe0f Offline",
    ),
    (
        {
            "frontends": [
                {
                    "name": "localhost",
                    "shortname": "local_server1",
                }
            ]
        },
        f"\n\u274c local_server1 (127.0.0.1) \u27a1\ufe0f Offline",
    ),
    (
        {
            "frontends": [
                {
                    "name": "localhost",
                    "availability": False,
                }
            ]
        },
        f"\n\u2b55\ufe0f localhost (DNS name not available) \u27a1\ufe0f Disabled",
    ),
]


@pytest.mark.parametrize("server_list, result", GET_SERVER_STATUS_TEST_DATA)
def test_get_servers_status_4bot(server_list, result):
    test_result = ic(get_servers_status_4bot(server_list))
    assert test_result == result


class TestGetDockerStatus(unittest.TestCase):

    @patch("subprocess.run")
    def test_get_docker_status(self, mock_subprocess_run):
        # Задаем фальшивый результат команды
        mock_result = Mock()
        mock_result.stdout = str(
            '[{"ContainerID": "12345", "Image": "nginx", "Status": "Up"}]'
        )
        mock_subprocess_run.return_value = mock_result

        expected_output = [{"ContainerID": "12345", "Image": "nginx", "Status": "Up"}]
        actual_output = ic(get_docker_status())

        self.assertEqual(expected_output, actual_output)
        mock_subprocess_run.assert_called_once_with(
            ["docker", "ps", "--format", "json"],
            capture_output=True,
            text=True,
            timeout=5,
        )
