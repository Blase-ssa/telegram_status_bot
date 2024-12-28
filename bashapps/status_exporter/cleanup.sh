#!/usr/bin/env bash

nc -vz $SRV_ADDR $SRV_PORT > /dev/null 2>&1
exit 0