#!/bin/bash

set -x

if [[ $(id -u) -ne 0 ]] ; then
  echo "Must be run as root"
  exit 1
fi

DEBIAN_FRONTEND=noninteractive apt-get update
  
#install NTP
DEBIAN_FRONTEND=noninteractive apt-get install -y ntp
  
DEBIAN_FRONTEND=noninteractive apt-get install -y unzip zip
  
#install java
DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:openjdk-r/ppa
DEBIAN_FRONTEND=noninteractive apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get purge -y openjdk-\*
DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk

