#!/usr/bin/env bash
#################################################
## simple script to load environment variables
#################################################
if [ -f ".env" ]; then
	source .env
fi

python3 main.py
