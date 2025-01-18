# Telegram status bot

## Introduction

This repository contains my bot for telegram.
The main task of the bot is to inform me about the state of my servers. if any of them is not available I should know about it.
At the moment the bot has minimal functionality:

1. Output user's data for registration in the bot (command /start) (registration is done manually by adding user to YAML file)
2. Execute the /status command, which checks the availability of servers from the frontend list by checking the availability of a certain port.
3. Output help when executing the /help command.
4. Also the bot will not allow to execute any other command except /start if the user is not registered.

In the future we plan to add a module that checks the status of containers and services. Plus add automatic notification of registered users in case of unavailability of one of the servers.

## How to run

### Common steps for all launch methods

* crete bot using "botfather", more about it here: <https://core.telegram.org/bots/tutorial>
* rename `./pyapps/example.env` to `./pyapps/.env` and edit the file
  * `BOTTOKEN` - Set to bot token you got from <https://telegram.me/BotFather>
  * `SELFADDR` - Self service address. Set `localhost` if you don't have public address.
* rename `./pyapps/example_conf` to `./pyapps/conf`
  * Edit all files inside `./pyapps/conf`. There will be descriptions inside each file with example.

### Local running without a container

**Not recommended!** This method is provided for testing the bot on a local PC.

* Install python and dependencies

```bash
sudo apt update && sudo apt install -y python3 python3-pip python-is-python3
pip install -r requirements.txt
```

* Run `start.sh` bash script

```bash
bash start.sh
```

This is an example of running a bot on Linux, on Windows you can run the bot using WSL or by replacing the environment variable settings with the settings in the options.yaml file. Then you can use the command to run it:

```cmd
python3 main.py
```

### Launch in a container

**Recomended**

1. Clone repository to the destination server
1. Perform all actions from point "### Common steps for all launch methods"
1. go to `./infrastructure/docker/`
1. execute command to build and start the container

```bash
docker compose up -d
```

### Luanch in Lambda (monitoring server only)

**Under construction**

1. Clone repository
1. Install Terraform (<https://developer.hashicorp.com/terraform/install>)
1. install and configure AWS CLI (<https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>)
1. Perform all actions from point "### Common steps for all launch methods"
1. go to `./infrastructure/AWS_Lambda/`
1. execute command to deploy in AWS

```bash
terraform init # to init terraform and download all plugins
terraform terraform apply
```

## Repository structure

* `pyapps` - contains a set of applications written in Python for this project
  * `conf` - this folder does not exists in the repository, but should be created to store configuration files
  * `example_conf` - use this folder as a reference for creation of conf folder
  * `tests` - set of unit tests I created to simplify development
* `infrastructure` - contains infrastructure code for quick launch of the application
  * `docker` - contains configs to quickly bring up a docker container
  * `AWS_Lambda` - contains Terraform script for launching a bot in AWS Lambda

<pre>
 telegram_status_bot
├──  infrastructure        - infrastructure code directory
│  ├──  AWS_Lambda
│  │  └──  main.tf         - terraform script to run bot in AWS Lambda
│  └──  docker
│     ├──  compose.yaml    - docker compose file to build image and run the container with app
│     └──  Dockerfile      - dockerfile to build image for apps
├──  bashapps              - bash scripts and apps
│  └──  status_exporter    - Directory with server app which provide monitoring data for bot and other apps
├──  pyapps                - dir with Python apps
│  └──  telegram_bot
│     ├──  common_imports.py  - a set of common libraries for all files
│     ├──  conf
│     │  ├──  access.yaml     - list of users and their privileges
│     │  ├──  options.yaml    - options for apps (can be replaced with environment variables)
│     │  └──  servers.yml     - list of servers and servicess to monitor
│     ├──  core_functions.py  - core functions for all apps
│     ├──  database.py        - database functions
│     ├──  globals.py         - global variables for all apps
│     ├──  main.py            - main file to run bot
│     ├──  monitoring_func.py - monitoring functions
│     ├──  monitoring_srv.py  - monitoring service, can be launched separately from the bot
│     ├──  pybot.py           - telegram bot, can be launched separately, if there is no need to run monitoring services
│     ├──  requirements.txt
│     ├──  start.sh           - bash scrip to run bot localy
│     └──  tests              - tests for apps
│        ├──  requirements.txt
│        ├──  test_core_functions.py
│        └──  test_monitoring_func.py
└──  Readme.md
</pre>
