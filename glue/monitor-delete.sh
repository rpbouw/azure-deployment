#!/bin/bash
RESOURCE_GROUP=rg-d01-app-onlinedatastore-003
SUBSCRIPTION=RABO-D01-CloudDelivery
VM=das-monitor
STORAGE_NAME=monitor
DISK_NAME=monitor


azure account set RABO-D01-CloudDelivery

azure vm delete -g $RESOURCE_GROUP -q $VM
azure network nic delete -g $RESOURCE_GROUP -q $VM-nic

export AZURE_STORAGE_ACCOUNT=$(azure storage account list | grep $STORAGE_NAME | awk '{print $2}')
echo "Using storage account $AZURE_STORAGE_ACCOUNT"

#export AZURE_STORAGE_ACCESS_KEY=$(azure storage account keys list $AZURE_STORAGE_ACCOUNT -g $RESOURCE_GROUP | grep Full | head -n 1 | awk '{print $3}')
#echo "Using access key: $AZURE_STORAGE_ACCESS_KEY"

# Remove individual disks:
#azure storage blob list --container disks -a $AZURE_STORAGE_ACCOUNT -k $AZURE_STORAGE_ACCESS_KEY | grep $DISK_NAME | awk '{system("azure storage blob delete --container disks -a $AZURE_STORAGE_ACCOUNT -k $AZURE_STORAGE_ACCESS_KEY -q -b " $2)}'

azure storage account delete -g $RESOURCE_GROUP -s $SUBSCRIPTION -q $STORAGE_NAME