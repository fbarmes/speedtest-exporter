FROM debian:buster-slim


#-------------------------------------------------------------------------------
# install system packages
#-------------------------------------------------------------------------------

RUN \
  #
  # update system
  #
  apt-get update &&\
  #
  # system basics
  #
  apt-get install -y procps cron rsyslog &&\
  #
  # dependencies
  #
  apt-get install -y gnupg1 apt-transport-https dirmngr &&\
  #
  # install speedtest
  #
  export INSTALL_KEY=379CE192D401AB61 &&\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${INSTALL_KEY} &&\
  echo "deb https://ookla.bintray.com/debian generic main" | tee  /etc/apt/sources.list.d/speedtest.list &&\
  apt-get update &&\
  apt-get install -y speedtest &&\
  #
  # install python
  #
  apt-get install -y python3


#-------------------------------------------------------------------------------
# install exporter
#-------------------------------------------------------------------------------
COPY  target/speedtest-exporter /opt/speedtest-exporter


#-------------------------------------------------------------------------------
# system files and entrypoint
#-------------------------------------------------------------------------------
COPY ./dockerroot/ /
RUN chmod 755 /docker-entrypoint*.sh


#-------------------------------------------------------------------------------
# workdir
#-------------------------------------------------------------------------------
EXPOSE 9100
WORKDIR /opt/speedtest-exporter

ENTRYPOINT ["/docker-entrypoint.sh"]
