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

setup_user()
{
  user=$1
  sshkey=$2
  
  adduser $user
  adduser $user sudo
  echo $user ALL=(ALL) NOPASSWD:ALL >>/etc/sudoers.d/90-cloud-init-users
  mkdir /home/$user/.ssh
  echo $sshkey >/home/$user/.ssh/authorized_keys
  chown -R $user:$user /home/$user/.ssh/
  chmod 0700 /home/$user/.ssh/
  chmod 0600 /home/$user/.ssh/authorized_keys
}

setup_users()
{
  setup_user willem "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfU9i09pTVIAMveswtrKjVK5Ht8E3nmRvK5KTQh554tdMP6qVUbk30SQLtBHN9wFkJqTjZCG3frtN2vE5Niebn/2YhLd6UINxyfroF+hKud5x/T4E085hFwEdXcIv44vr9kWbb/kCzAEzsjn14q6Sh3yyuPayIs6Zyd+Yj3QtGerIvetPK7oeEv2V6AavhARmIjY6nBO52eha/+zLHsCyA5cl/MbtjQNXQHTuzjxsBSPjqnIKehguHZRGqY/FqK+m0KX1qSBhf45dtllJg96PjGB02cUvj9CJJ3jt/J1PD3brJDZ2VVo0yoJC+dXEQUfTPtAzAmzBDX01TV6Dxhci/"
  setup_user jagodevreede "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6J/h+LCED+2J1s6D/jvaiKZ8S/vBquEHTyaGRkrutqd9YsnXA/zwde5IZPkUffa8Sikku5BJ5ucfik57rJFBn0FazdqTxHzbXyueYyaljeFjh9o4EXUK+xzk+efjbprKT9QeA8uCbzbUSXsbZOWZtZnQibgHhzrsiqym/ZCmnggxPU1xD0iBOk0U3vEhKPU6YIOuZvdONum2f0uPY6qwQQDgHv9bQpSWtft8pUIOfafSn1ESll5nyLrnw6vMi9DFnqUmLarlHqRt1eF45Dbrx65d7J6BVCuecrC3e+AtLreqt5ft7apaWfhCo4C45h5+hbd3BCBMvaQ15hBA5Y/YrB54HE2nrfHrYUvEF4xUcN5XxrNvE7uRkLVzfHCNFBYkwL3ikG5V0SyHvHX5bUTAwa6rOjSqSysMR5iR9eU5k6BHGl+eI32cfo5CTNOpVjMVn3O4qYKsAfcHtWetn/nChda9ZOIbEbfSLB+V91ibWK5n2LdAQkyJsBxdBpnI/WcruNco/e6ac5hDbYAjYyKbpJK2s69huUZGP6/d7/yypeHnWzabJssBNL5awJYuRw5cH8y3IycVypPFVuFIR2Y61p9OHJIAU/3EXYAoBSl+KMXql8a3m0sjJ2NQNc3oED3qI2+wIqr1yAh4k0M8JAT9Mp+Bq0LV93IrvYDI1UA69mQ=="
}

install_packages_ubuntu
setup_dynamicdata_disks $MNT_POINT
