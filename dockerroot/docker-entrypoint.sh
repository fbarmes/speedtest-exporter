#!/bin/bash

echo "[INFO] Entrypoint start"
echo "ARGS: $@"
echo "pwd: $(pwd)"


#-------------------------------------------------------------------------------
# init
#-------------------------------------------------------------------------------
mkdir -p /opt/data/speedtest

#-------------------------------------------------------------------------------
# setup and launch crontab
#-------------------------------------------------------------------------------
echo "[INFO] setup and launch crontab"
chmod 755 /etc/cron.d/*
service rsyslog start
service cron start


#-------------------------------------------------------------------------------
# run first test
#-------------------------------------------------------------------------------
# echo "[INFO] run speedtest"
# /opt/speedtest-exporter/speedtest_runner.py --json-file /opt/speedtest.json --csv-file /opt/speedtest.csv


#-------------------------------------------------------------------------------
# Start exporter
#-------------------------------------------------------------------------------
echo "[INFO] start exporter"
./speedtest_exporter.py --json-file /opt/data/speedtest/speedtest.json --listen-address 0.0.0.0:9100
# bash $@
