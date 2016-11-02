#!/bin/bash

set -x

if [[ $(id -u) -ne 0 ]] ; then
  echo "Must be run as root"
  exit 1
fi

if [ $# != 4 ]; then
  echo "Usage: $0 <MasterHostname> <mountFolder> <numDataDisks> <adminUserName>"
  exit 1
fi

MASTER_HOSTNAME=$1
MNT_POINT="$2"
SHARE_HOME=$MNT_POINT/home
SHARE_DATA=$MNT_POINT/data

numberofDisks="$3"
userName="$4"

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
    devices=`echo $createdPartitions | wc -w`
    mdadm --create /dev/md10 --level 0 --raid-devices $devices $createdPartitions
    mkfs -t ext4 /dev/md10
    echo "/dev/md10 $mountPoint ext4 defaults,nofail 0 2" >> /etc/fstab
    mount /dev/md10
  fi
}

# Creates and exports two shares on the node:
#
# /share/home 
# /share/data
#
setup_shares()
{
  mkdir -p $SHARE_HOME
  mkdir -p $SHARE_DATA

  setup_dynamicdata_disks $SHARE_DATA
  echo "$SHARE_HOME    *(rw,async)" >> /etc/exports
  echo "$SHARE_DATA    *(rw,async)" >> /etc/exports

  DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::Options::=--force-confdef -o DPkg::Options::=--force-confold install nfs-kernel-server
  /etc/init.d/apparmor stop 
  /etc/init.d/apparmor teardown 
  update-rc.d -f apparmor remove
  apt-get -y remove apparmor
  systemctl start rpcbind || echo "Already enabled"
  systemctl start nfs-server || echo "Already enabled"
  systemctl start nfs-kernel-server.service
  systemctl enable rpcbind || echo "Already enabled"
  systemctl enable nfs-server || echo "Already enabled"
  systemctl enable nfs-kernel-server.service
}

set_time()
{
    mv /etc/localtime /etc/localtime.bak
    ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
}

install_packages_ubuntu()
{
  DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g zlib1g-dev  bzip2 libbz2-dev libssl1.0.0  libssl-doc libssl1.0.0-dbg libsslcommon2 libsslcommon2-dev libssl-dev  nfs-common rpcbind git zip libicu55 libicu-dev icu-devtools unzip mdadm wget gsl-bin libgsl2  bc ruby-dev gcc make autoconf bison build-essential libyaml-dev libreadline6-dev libncurses5 libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libpam0g-dev libxtst6 libxtst6-* libxtst-* libxext6 libxext6-* libxext-* git-core libelf-dev asciidoc binutils-dev fakeroot crash kexec-tools makedumpfile kernel-wedge portmap
  DEBIAN_FRONTEND=noninteractive apt-get -y build-dep linux
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  DEBIAN_FRONTEND=noninteractive update-initramfs -u
}

install_cassandra()
{
  #install cassandra on ubuntu 16.04 LTS
  
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
  DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties debconf-utils
  add-apt-repository -y ppa:webupd8team/java
  DEBIAN_FRONTEND=noninteractive apt-get update
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer
  
  #install cassandra
  echo "deb http://www.apache.org/dist/cassandra/debian 39x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
  echo "deb-src http://www.apache.org/dist/cassandra/debian 39x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
  curl https://www.apache.org/dist/cassandra/KEYS | apt-key add -
  
  DEBIAN_FRONTEND=noninteractive apt-get update
  
  DEBIAN_FRONTEND=noninteractive apt-get install -y cassandra
  
  chown -R cassandra:cassandra /data/data
  
  service cassandra stop
  rm -rf /var/lib/cassandra/data
  
  IPADDRESS=$(ifconfig -a|grep "inet addr"|grep -v 127|awk '{print $2;}'|awk -F: '{print $2;}')
  sed -i s/"localhost"/"$IPADDRESS"/g /etc/cassandra/cassandra.yaml
  
  CPU_CORES=$(nproc --all)
  sed -i s/"#concurrent_compactors: 1"/"concurrent_compactors: $CPU_CORES"/g /etc/cassandra/cassandra.yaml
  
  sed -i s/"\/var\/lib\/cassandra\/data"/"\/data\/data"/g /etc/cassandra/cassandra.yaml
  
  sed -i s/"cluster_name:.*\$"/"cluster_name: 'DatastoreTest'"/g /etc/cassandra/cassandra.yaml
  sed -i s/"- seeds:.*\$"/"- seeds: \"10.0.1.4,10.0.1.5\""/g /etc/cassandra/cassandra.yaml
  
  
  echo "#custom settings" >> /etc/cassandra/jvm.options
  echo "-Dcassandra.logdir=/mnt" >> /etc/cassandra/jvm.options
  
  service cassandra start
}

install_packages_ubuntu
setup_shares
install_cassandra
