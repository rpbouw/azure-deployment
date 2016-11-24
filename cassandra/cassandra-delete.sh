azure account set RABO-D01-CloudDelivery

VM=cas-we1
azure vm delete -g RG-D01-APP-ONLINEDATASTORE-002 -q $VM
azure network nic delete -g RG-D01-APP-ONLINEDATASTORE-002 -q $VM-nic

#to be detailed:
#determine container, connection and key
azure storage blob list --container disks -a q7vrgjmvjm6oicassandra -k SyKzlAIlQ9SoJk4gFq6eoWgw1QX2Z7p1h+36+FdKk2uBl7plJ6ZqmJX2ai3TBPS9YSBoYkDloxsBUGiVr479SA== | grep $VM| awk '{print "azure storage blob delete --container disks -a q7vrgjmvjm6oicassandra -k SyKzlAIlQ9SoJk4gFq6eoWgw1QX2Z7p1h+36+FdKk2uBl7plJ6ZqmJX2ai3TBPS9YSBoYkDloxsBUGiVr479SA== -q -b " $2}'
