#!/bin/bash

set -x

if [[ $(id -u) -ne 0 ]] ; then
  echo "Must be run as root"
  exit 1
fi

if [ $# != 4 ]; then
  echo "Usage: $0 <MasterHostname> <numDataDisks> <adminUserName> <datacenter>"
  exit 1
fi

MASTER_HOSTNAME=$1
MNT_POINT="/data"
numberofDisks="$2"
userName="$3"
datacenter="$4"

setup_dynamicdata_disks()
{
  mountPoint="$1"
  createdPartitions=""

  # Loop through and partition disks until not found
  if [ "$numberofDisks" == "1" ]
  then
     disking=( sdc )
  elif [ "$numberofDisks" == "2" ]; then
     disking=( sdc sdd )
  elif [ "$numberofDisks" == "3" ]; then
     disking=( sdc sdd sde )
  elif [ "$numberofDisks" == "4" ]; then
     disking=( sdc sdd sde sdf )
  elif [ "$numberofDisks" == "5" ]; then
     disking=( sdc sdd sde sdf sdg )
  elif [ "$numberofDisks" == "6" ]; then
     disking=( sdc sdd sde sdf sdg sdh )
  elif [ "$numberofDisks" == "7" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi )
  elif [ "$numberofDisks" == "8" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj )
  elif [ "$numberofDisks" == "9" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk )
  elif [ "$numberofDisks" == "10" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl )
  elif [ "$numberofDisks" == "11" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm )
  elif [ "$numberofDisks" == "12" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn )
  elif [ "$numberofDisks" == "13" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo )
  elif [ "$numberofDisks" == "14" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp )
  elif [ "$numberofDisks" == "15" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq )
  elif [ "$numberofDisks" == "16" ]; then
     disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr )
  fi

  printf "%s\n" "${disking[@]}"

  for disk in "${disking[@]}"
  do
    fdisk -l /dev/$disk || break
    fdisk /dev/$disk << EOF
n
p
1


t
fd
w
EOF
    createdPartitions="$createdPartitions /dev/${disk}1"
  done

  # Create RAID-0 volume
  if [ -n "$createdPartitions" ]; then
    mkdir /data
    DEBIAN_FRONTEND=noninteractive apt-get install -y mdadm
    devices=`echo $createdPartitions | wc -w`
    mdadm --create /dev/md10 --level 0 --raid-devices $devices $createdPartitions
    mkfs -t ext4 /dev/md10
    echo "/dev/md10 $mountPoint ext4 defaults,nofail 0 2" >> /etc/fstab
    mount /dev/md10
  fi
}

install_packages_ubuntu()
{
  #DEBIAN_FRONTEND=noninteractive apt-get -y build-dep linux
  #DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  DEBIAN_FRONTEND=noninteractive update-initramfs -u
}

install_cassandra()
{
  #install cassandra on ubuntu
  
  set -x
  
  if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
  fi
  
  DEBIAN_FRONTEND=noninteractive apt-get update
  
  #install NTP
  DEBIAN_FRONTEND=noninteractive apt-get install -y ntp
  
  # only if we use SDD:
  #https://docs.datastax.com/en/cassandra/2.0/cassandra/install/installRecommendSettings.html
  #echo 0 > /sys/class/block/sdc/queue/rotational
  #echo 8 > /sys/class/block/sdc/queue/read_ahead_kb
  
  chmod a+w /mnt
  
  #install java
  DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:openjdk-r/ppa
  DEBIAN_FRONTEND=noninteractive apt-get update 
  DEBIAN_FRONTEND=noninteractive apt-get purge -y openjdk-\*
  DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk

#  DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties debconf-utils
#  add-apt-repository -y ppa:webupd8team/java
#  DEBIAN_FRONTEND=noninteractive apt-get update
#  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
#  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer
  
  #install cassandra
  echo "deb http://www.apache.org/dist/cassandra/debian 39x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
  echo "deb-src http://www.apache.org/dist/cassandra/debian 39x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
  curl https://www.apache.org/dist/cassandra/KEYS | apt-key add -
  
  DEBIAN_FRONTEND=noninteractive apt-get update
  
  DEBIAN_FRONTEND=noninteractive apt-get install -y cassandra
  
  chown -R cassandra:cassandra /data
  
  service cassandra stop
  rm -rf /var/lib/cassandra/data
  
  IPADDRESS=$(ifconfig -a|grep "inet addr"|grep -v 127|awk '{print $2;}'|awk -F: '{print $2;}')
  sed -i s/"localhost"/"$IPADDRESS"/g /etc/cassandra/cassandra.yaml
  
  CPU_CORES=$(nproc --all)
  sed -i s/"#concurrent_compactors: 1"/"concurrent_compactors: $CPU_CORES"/g /etc/cassandra/cassandra.yaml
  
  sed -i s/"\/var\/lib\/cassandra\/data"/"\/data"/g /etc/cassandra/cassandra.yaml
  
  sed -i s/"cluster_name:.*\$"/"cluster_name: 'DatastoreTest'"/g /etc/cassandra/cassandra.yaml
  sed -i s/"- seeds:.*\$"/"- seeds: \"10.1.0.36,10.1.0.37\""/g /etc/cassandra/cassandra.yaml
  
  sed -i s/"endpoint_snitch:.*\$"/"endpoint_snitch: GossipingPropertyFileSnitch"/g /etc/cassandra/cassandra.yaml
  
  RACK=`grep randomId /var/lib/waagent/SharedConfig.xml|gawk 'BEGIN { FS="\"" }; { print $2 }'`
  sed -i s/"rack=.*\$"/"rack=rack$RACK"/g /etc/cassandra/cassandra-rackdc.properties
  sed -i s/"dc=.*\$"/"dc=$datacenter"/g /etc/cassandra/cassandra-rackdc.properties
  
  echo "#custom settings" >> /etc/cassandra/jvm.options
  echo "-Dcassandra.logdir=/mnt" >> /etc/cassandra/jvm.options
  
  service cassandra start
}

install_packages_ubuntu
setup_dynamicdata_disks $MNT_POINT
install_cassandra
