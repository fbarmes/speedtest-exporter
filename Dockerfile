
#===============================================================================
# Base image
#===============================================================================

ARG BASE_IMAGE
FROM ${BASE_IMAGE} as base

#-- install system packages
RUN \
  # update
  apt-get update &&\
  # python
  apt-get install -y python3 &&\
  # install speedtest
  apt-get install -y gnupg1 apt-transport-https dirmngr &&\
  export INSTALL_KEY=379CE192D401AB61 &&\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${INSTALL_KEY} &&\
  echo "deb https://ookla.bintray.com/debian generic main" | tee  /etc/apt/sources.list.d/speedtest.list &&\
  apt-get update &&\
  apt-get install -y speedtest



#===============================================================================
# Dev/Builder image
#===============================================================================
FROM base as dev

#-- install system packages
RUN \
  # build tools
  apt-get install -y make python3-pip &&\
  # build folder
  mkdir -p /workdir/src/

#-- define workdir
WORKDIR /workdir

#-- copy sources
COPY requirements.txt Makefile VERSION /workdir/

#-- add dependencies
RUN make dev-deps

#-- add source code
COPY src/* /workdir/src/

#-- build
RUN make dev-build

#===============================================================================
# Run image
#===============================================================================
FROM base as final

RUN \
  # system basics
  apt-get install -y procps cron rsyslog

#-------------------------------------------------------------------------------
# install exporter
#-------------------------------------------------------------------------------
COPY --from=dev /workdir/target/speedtest-exporter /opt/speedtest-exporter

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
