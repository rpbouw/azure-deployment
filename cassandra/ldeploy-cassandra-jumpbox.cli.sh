azure account set RABO-D51-CloudDelivery-Unmanaged
#azure group create -n RG-D51-APP-ONLINEDATASTORE-002 -l "West Europe"
azure group deployment create --template-file azuredeploy-cassandra-jumpbox.json \
     -e azuredeploy-cassandra-jumpbox.parameters.json \
     -g RG-D51-APP-ONLINEDATASTORE-002 \
     -n CassandraJBDeployment
