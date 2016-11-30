#!/bin/bash

set -x

if [[ $(id -u) -ne 0 ]] ; then
  echo "Must be run as root"
  exit 1
fi

DEBIAN_FRONTEND=noninteractive

apt-get update
  
#install NTP
apt-get install -y ntp
  
apt-get install -y unzip zip
  
#install java
add-apt-repository -y ppa:openjdk-r/ppa
apt-get update 
apt-get purge -y openjdk-\*
apt-get install -y openjdk-8-jdk
