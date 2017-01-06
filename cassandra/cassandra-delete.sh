if [ $# != 1 ]; then
  echo "Usage: $0 vmNumber"
  exit 1
fi

VM=das-cas$1

azure account set RABO-D51-CloudDelivery-Unmanaged

azure vm delete -g RG-D51-APP-ONLINEDATASTORE-002 -q $VM
azure network nic delete -g RG-D51-APP-ONLINEDATASTORE-002 -q $VM-nic

#to be detailed:
#determine container, connection and key
#azure storage blob list --container disks -a q7vrgjmvjm6oicassandra -k SyKzlAIlQ9SoJk4gFq6eoWgw1QX2Z7p1h+36+FdKk2uBl7plJ6ZqmJX2ai3TBPS9YSBoYkDloxsBUGiVr479SA== | grep $VM| awk '{print "azure storage blob delete --container disks -a q7vrgjmvjm6oicassandra -k SyKzlAIlQ9SoJk4gFq6eoWgw1QX2Z7p1h+36+FdKk2uBl7plJ6ZqmJX2ai3TBPS9YSBoYkDloxsBUGiVr479SA== -q -b " $2}'
