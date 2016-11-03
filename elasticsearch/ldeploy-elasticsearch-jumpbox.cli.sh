azure account set RABO-D51-CloudDelivery-Unmanaged
#azure group create -n RG-D51-APP-ONLINEDATASTORE-001 -l "West Europe"
azure group deployment create --template-file azuredeploy-elasticsearch-jumpbox.json \
     -e azuredeploy-elasticsearch-jumpbox.parameters.json \
     -g RG-D51-APP-ONLINEDATASTORE-001 \
     -n ElasticsearchJBDeployment
