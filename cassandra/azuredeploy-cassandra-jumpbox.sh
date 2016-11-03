#!/bin/bash

set -x

if [[ $(id -u) -ne 0 ]] ; then
  echo "Must be run as root"
  exit 1
fi

if [ $# != 2 ]; then
  echo "Usage: $0 <mountFolder> <numDataDisks>"
  exit 1
fi

MNT_POINT="$1"
numberofDisks="$2"

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

install_packages_ubuntu()
{
  DEBIAN_FRONTEND=noninteractive apt-get install -y git zip unzip mdadm wget
  #DEBIAN_FRONTEND=noninteractive apt-get -y build-dep linux
  #DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  DEBIAN_FRONTEND=noninteractive update-initramfs -u
  #install java
  DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties debconf-utils
  DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:webupd8team/java
  DEBIAN_FRONTEND=noninteractive apt-get update
  DEBIAN_FRONTEND=noninteractive echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer
}

install_packages_ubuntu
setup_dynamicdata_disks $MNT_POINT
