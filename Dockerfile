FROM debian:buster-slim

#-------------------------------------------------------------------------------
# update package list
#-------------------------------------------------------------------------------
RUN apt-get update


#-------------------------------------------------------------------------------
# install speedtest
#-------------------------------------------------------------------------------
RUN \
  apt-get install -y gnupg1 apt-transport-https dirmngr


# Other non-official binaries will conflict with Speedtest CLI
# Example how to remove using apt-get
# sudo apt-get remove speedtest-cli

RUN \
  export INSTALL_KEY=379CE192D401AB61 &&\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${INSTALL_KEY} &&\
  echo "deb https://ookla.bintray.com/debian generic main" | tee  /etc/apt/sources.list.d/speedtest.list &&\
  apt-get update &&\
  apt-get install -y speedtest


#-------------------------------------------------------------------------------
# install python
#-------------------------------------------------------------------------------
RUN \
  apt-get install -y python3

#-------------------------------------------------------------------------------
# Environment
#-------------------------------------------------------------------------------
ENV ST_ARG_SERVER_ID=""


#-------------------------------------------------------------------------------
# install python
#-------------------------------------------------------------------------------
COPY  target/speedtest-exporter /opt/speedtest-exporter

#-------------------------------------------------------------------------------
# Entrypoint
#-------------------------------------------------------------------------------
# COPY ./root/ /
# RUN chmod 755 /docker-entrypoint-*.sh

#-------------------------------------------------------------------------------
# workdir
#-------------------------------------------------------------------------------
WORKDIR /opt/speedtest-exporter

# ENTRYPOINT ["/docker-entrypoint.sh"]
