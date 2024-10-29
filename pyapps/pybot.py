#!/usr/bin/env python3

from common_imports import *

from database import *
from monitoring_func import *

# to add date in some response
from datetime import datetime


# telegram bot libs
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler

# import globals


def pybot_main():
    # precheck
    if server_list is None:
        raise LookupError("No server configuration file provided")
    if globals.BOTTOKEN is None:
        raise LookupError("No server configuration file provided")
    # run bot
    application = ApplicationBuilder().token(globals.BOTTOKEN).build()
    start_handler = CommandHandler("start", bot_start)
    help_handler = CommandHandler("help", bot_help)
    search_handler = CommandHandler("search", bot_search)
    status_handler = CommandHandler("status", bot_status)

    application.add_handler(start_handler)
    application.add_handler(help_handler)
    application.add_handler(search_handler)
    application.add_handler(status_handler)
    application.run_polling()


async def bot_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    if globals.REGISTRATION:
        response_message = (
            f"Здравствуйте, {user.first_name}!\n"
            f"Для получения доступа к боту отправьте следующие данные его владельцу:\n"
            f"```\n"
            f"Ваш ID: \t{user.id}\n"
            f"Имя: \t{user.first_name}\n"
            f"Имя пользователя: \t@{user.username}\n"
            f"```"
        )
    else:
        response_message = f"Регистрация в боте временно не доступна."
    await context.bot.send_message(
        chat_id=update.effective_chat.id, text=response_message
    )


async def bot_help(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    if get_access(user.id, "help"):
        response_message = get_help(user.id)
        await context.bot.send_message(
            chat_id=update.effective_chat.id, text=response_message
        )


async def bot_search(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    if get_access(user.id, "search"):
        response_message = search_database()
        await context.bot.send_message(
            chat_id=update.effective_chat.id, text=response_message
        )


async def bot_status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    if get_access(user.id, "status"):
        response_message = get_servers_status_4bot(server_list)
        current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        response_message = f"{current_datetime}\n{response_message}"
        await context.bot.send_message(
            chat_id=update.effective_chat.id, text=response_message
        )


if __name__ == "__main__":
    globals.BOTTOKEN = get_secret("BOTTOKEN")
    pybot_main()
