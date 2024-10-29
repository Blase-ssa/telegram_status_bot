"""
    this file created to store common global variables
"""

SERVER_LIST_FILENAME_PROTOTYPE: str = "servers"
SERVER_LIST_FILENAME: str = None  # TODO: после тестов заменить на значение по умолчанию
BOTTOKEN: str = None

REGISTRATION: bool = True  # False
USER_DB = "access.yaml"  # defualt filename for users database #TODO: добавить функцию для проверки имени файла из YAML файла

# default help message, if no permissions found but user have been registered
DEFAULT_HELP = (
    f"Вам доступны следующие функции бота:\n"
    "/help - для вывода данного сообщения\n"
    "/status - для быстрой проверки статуса серверов"
)

CONFIGDIR: str = "./config"

#
GET_STATUS_TIME: int = 10 * 60
