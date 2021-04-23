#!/usr/bin/env python3
#
#

#-- PYPI dependencies
from flask import Flask
from waitress import serve
from prometheus_client import make_wsgi_app, Gauge

#-- standard dependencies
import logging
import getopt
import sys
import json

#-- internal modules
from ookla_client import OoklaClient


#-------------------------------------------------------------------------------
# setup logging
#-------------------------------------------------------------------------------
logger = logging.getLogger('root')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler(sys.stdout)
formatter=logging.Formatter("[%(asctime)s] [%(levelname)8s]: %(message)s", "%Y-%m-%d %H:%M:%S")
ch.setFormatter(formatter)
logger.addHandler(ch)

#-------------------------------------------------------------------------------
# Init Flask application
#-------------------------------------------------------------------------------
app = Flask("speedtest_exporter")

#-------------------------------------------------------------------------------
# Define Prometheus metrics
#-------------------------------------------------------------------------------
speedtest_ping = Gauge('speedtest_ping', 'ping time in ms')
speedtest_download = Gauge('speedtest_download', 'speedtest download speed in Mbit/s')
speedtest_upload = Gauge('speedtest_upload', 'speedtest upload speed in Mbit/s')

#-------------------------------------------------------------------------------
# OoklaClient
#-------------------------------------------------------------------------------
ookla_client=None

http_listen_address="0.0.0.0:9100"
data_source_file="/tmp/speedtest.json"

#-------------------------------------------------------------------------------
""" script usage
"""
def usage():
    print ("This is the usage function")
    print(sys.argv[0])
    print("""
        \t--listen-address 0.0.0.0:9100
        \t-f, --json-file /tmp/speedtest.json
    """)


#-------------------------------------------------------------------------------
@app.route('/')
def home_page():
    return """
    <h1>Speedtest exporter</h1>
    <a href="/metrics">metrics</a>
    """

#-------------------------------------------------------------------------------
@app.route('/metrics')
def metrics_page():

    #-- Get data
    speedtest_data = load_data_from_file(data_source_file)
    logger.info("speedtest data= {}".format(speedtest_data))

    #-- set data in prometheus gauges
    speedtest_ping.set( float(speedtest_data['ping']) )
    speedtest_download.set( float(speedtest_data['download']) )
    speedtest_upload.set( float(speedtest_data['upload']) )

    return make_wsgi_app()

#-------------------------------------------------------------------------------
""" load data from file
"""
def load_data_from_file(filename):
    with open(filename) as json_file:
        data = json.load(json_file)
    return data

#-------------------------------------------------------------------------------
""" Main function
"""
def main():
    global ookla_client
    global data_source_file

    logger.info("Speedtest exporter Start")


    #-- get command line options
    try:
        shortopts="hf:"
        longopts=["help","json-file=","listen-address="]
        opts, args = getopt.getopt(sys.argv[1:], shortopts, longopts )
    except getopt.GetoptError as err:
        print(str(err))
        usage()
        sys.exit(2)

    #-- handle command line options
    for o, value in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-f", "--json-file"):
            data_source_file=value
        elif o in ("--listen-address"):
            http_listen_address=value
        else:
            assert False, "unhandled option {}".format(o)


    #-- instanciate ooklaClient
    ookla_client=OoklaClient()

    #-- start HTTP server
    http_listen_params = http_listen_address.split(':')
    http_listen_ip=http_listen_params[0]
    http_listen_port=http_listen_params[1]
    logger.info("Starting server listening on {}:{}".format(http_listen_ip,http_listen_port))
    serve(app, host=http_listen_ip, port=http_listen_port)

    logger.info("Speedtest exporter Done")

#-------------------------------------------------------------------------------
main()
