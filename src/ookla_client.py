import logging
import json
import subprocess

import tzlocal
import datetime

logger = logging.getLogger('root')

class OoklaClient:

    #-------------------------------------------------------------------------------
    """ Constructor
    """
    def __init__(self, dry_run=False):
        self.dry_run=dry_run

    #-------------------------------------------------------------------------------
    """ Run test and save data
    """
    def run(self):
        #-- run speedtest
        if( self.dry_run  ):
            logger.debug("Get data in DRY RUN mode")
            speedtest_data = {
                'datetime': '2021-04-09T08:25:31.111945+00:00',
                'ping': '1.23',
                'download': '575.08',
                'upload': '278.87'
            }
        else:
            logger.debug("Get data")
            speedtest_data = self.run_speedtest()

        return speedtest_data


    #-------------------------------------------------------------------------------
    """ convert bytes into Mb
    """
    def bytes_to_mbits(self, bytes):
        mbits = ( bytes * 8 )/(1024*1024)
        return round(mbits,2)


    #-------------------------------------------------------------------------------
    """ Run speedtest and extract metrics
    """
    def run_speedtest(self):
        logger.debug("Run speedtest START")

        #-- prepare response
        result = {
            'datetime':0,
            'ping':0,
            'download':0,
            'upload':0
        }

        #-- build command line argument
        cmd_args =  ""
        cmd_args += " --accept-license --accept-gdpr"
        cmd_args += " --format json"
        cmd = "speedtest "+cmd_args

        #-- run speedtest and load data
        json_data = {}
        try:
            logger.debug("command line: "+cmd)
            response = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE).stdout.read()

            logger.debug("RESPONSE")
            logger.debug(str(response))

            json_data = json.loads(response.decode('utf-8'))
        except Exception as e:
            pass

        #-- collect data
        logger.debug("get local time ...")
        local_tz = tzlocal.get_localzone()
        now_lima=datetime.datetime.now(tz=local_tz)
        result['datetime'] = now_lima.isoformat()

        #-- handle error
        if "error" in json_data:
            # there has been an error
            return result

        #-- handle result
        if ("type" in json_data) and (json_data["type"] == "result") :
            # there is a result
            logger.debug("there is a result")
            result['ping'] = "{:0.2f}".format(json_data['ping']['latency'])
            result['download'] = "{:0.2f}".format(self.bytes_to_mbits(json_data['download']['bandwidth']))
            result['upload'] = "{:0.2f}".format(self.bytes_to_mbits(json_data['upload']['bandwidth']))

        return result

    def toString(self):
        logger.error("HELLLO")
        result="OoklaClient: "
        result +=" dry_run={}".format(self.dry_run)
        return result
