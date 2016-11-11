# DEV environment
azure account set RABO-D51-CloudDelivery-Unmanaged

# network is defined in glue resource group

#west europe
azure group deployment create --template-file vnet-template.json \
    -e vnet-parameters-we.json \
    -g RG-D51-APP-ONLINEDATASTORE-003 \
    -n vnet-deployment-we

#north europe
azure group deployment create --template-file vnet-template.json \
    -e vnet-parameters-ne.json \
    -g RG-D51-APP-ONLINEDATASTORE-003 \
    -n vnet-deployment-ne
