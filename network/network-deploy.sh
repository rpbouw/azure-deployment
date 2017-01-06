# DEV environment
azure account set RABO-D51-CloudDelivery

# network is defined in glue resource group

azure group deployment create --template-file network.json \
    -g RG-D51-APP-ONLINEDATASTORE-003 \
    -n network-deployment
