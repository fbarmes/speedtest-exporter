#!/usr/bin/env python3
#
# speedtest_runner
#
# executes speedtest and saves the result
#
#
import os
import sys
import logging
import getopt
import json

#-- internal modules
from ookla_client import OoklaClient

#-------------------------------------------------------------------------------
# setup logging
#-------------------------------------------------------------------------------
logger = logging.getLogger('root')
logger.setLevel(logging.INFO)
ch = logging.StreamHandler(sys.stdout)
formatter=logging.Formatter("[%(asctime)s] [%(levelname)8s]: %(message)s", "%Y-%m-%d %H:%M:%S")
ch.setFormatter(formatter)
logger.addHandler(ch)


#-------------------------------------------------------------------------------
# OoklaClient
#-------------------------------------------------------------------------------
ookla_client=None


#-------------------------------------------------------------------------------
""" script usage
"""
def usage():
    print ("This is the usage function")
    print(sys.argv[0])
    print("""
        \t-f --json-file <json-output-file>
        \t-p --prom-file <prometheus-output-file>
        \t-c --csv-file <csv-output-file>
    """)



#-------------------------------------------------------------------------------
""" convert speedtest_data dict to prometheus format
"""
def data_to_prometheus_text(speedtest_data):
    result = "";
    result += '# HELP speedtest_ping ping time in ms\n'
    result += '# TYPE speedtest_ping gauge\n'
    result += 'speedtest_ping {}\n'.format(speedtest_data['ping'])
    result += '# HELP speedtest_download download speed in Mbit/s\n'
    result += '# TYPE speedtest_download gauge\n'
    result += 'speedtest_download {}\n'.format(speedtest_data['download'])
    result += '# TYPE speedtest_upload gauge\n'
    result += '# HELP speedtest_upload upload speed in Mbit/s\n'
    result += 'speedtest_upload {}\n'.format(speedtest_data['upload'])
    return result

#-------------------------------------------------------------------------------
""" Convert speedtest data to csv line
"""
def data_to_csv_line(speedtest_data):


    result = "{},{},{},{}\n".format(
        speedtest_data['datetime'],
        speedtest_data['ping'],
        speedtest_data['download'],
        speedtest_data['upload']
    )

    # sep=','
    # result = "";
    # result += speedtest_data['datetime'] + sep
    # result += speedtest_data['ping'] + sep
    # result += speedtest_data['download'] + sep
    # result += speedtest_data['upload']
    # result += '\n'
    return result

#-------------------------------------------------------------------------------
""" print to file
"""
def print_to_file(filename, data, append=False, header=None):

    #-- Open file
    file_open_mode="wt"
    if(append == True):
        file_open_mode="at"

    logger.debug("Open file [{}] with mode [{}]".format(filename,file_open_mode) )
    fh = open(filename, file_open_mode)

    #-- print first line
    try:
        if os.stat(filename).st_size == 0 and header is not None:
            logger.debug("write header")
            fh.write(header)
    except Exception as e:
        logger.error(e)
        pass

    #-- write data
    logger.debug("Write data")
    fh.write(data)
    fh.close()

#-------------------------------------------------------------------------------
""" get csv header line
"""
def get_csv_header():
    return "Date,Ping (ms),Download (Mbit/s),Upload (Mbit/s)\n"



#-------------------------------------------------------------------------------
""" Main function
"""
def main():

    global ookla_client


    #-- default values
    json_file=None
    pretty_json=False
    prom_file=None
    csv_file=None
    dry_run=False

    #-- start
    logger.info("speedtest runner START")

    #-- get command line options
    try:
        shortopts="hdf:p:c:"
        longopts=["help","dry-run","json-file=","prom-file=","csv-file=","pretty-json"]
        opts, args = getopt.getopt(sys.argv[1:], shortopts, longopts )
    except getopt.GetoptError as err:
        print(str(err))
        usage()
        sys.exit(2)

    #-- handle command line options
    for o, value in opts:

        logger.debug("argument o=[{}] value=[{}]".format(str(o),str(value)))

        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-f", "--json-file"):
            json_file=value
        elif o in ("--pretty-json"):
            pretty_json=True
        elif o in ("-p", "--prom-file"):
            prom_file=value
        elif o in ("-c", "--csv-file"):
            csv_file=value
        elif o in ("-d", "--dry-run"):
            dry_run=True
        else:
            assert False, "unhandled option {}".format(o)

    #-- Display some info
    logger.debug("json_file={}".format(json_file))
    logger.debug("prom_file={}".format(prom_file))
    logger.debug("csv_file={}".format(csv_file))
    logger.debug("dry_run={}".format(dry_run))
    logger.debug("pretty_json={}".format(pretty_json))


    #-- instanciate ooklaClient
    ookla_client=OoklaClient(dry_run=dry_run)
    logger.debug(ookla_client.toString())

    #-- run speedtest
    speedtest_data = ookla_client.run()
    logger.info("Speedtest data : {}".format(speedtest_data))


    #-- Handle json output
    if( json_file is not None ):
        logger.info("Write results to json file {}".format(json_file))
        if(pretty_json):
            json_string=json.dumps(speedtest_data, sort_keys=True, indent=4)
        else:
            json_string=json.dumps(speedtest_data)
        print_to_file(json_file, json_string, False)

    #-- Handle prom output
    if( prom_file is not None ):
        #-- output prometheus
        logger.info("Write results to prom file {}".format(prom_file))
        prom_string=data_to_prometheus_text(speedtest_data)
        print_to_file(prom_file, prom_string, append=False)

    #-- Handle csv output
    if( csv_file is not None ):
        logger.info("Write results to csv file {}".format(csv_file))
        csv_string=data_to_csv_line(speedtest_data)
        print_to_file(csv_file, csv_string, True, get_csv_header() )

    logger.info("speedtest ookla DONE")

#-------------------------------------------------------------------------------
main()
