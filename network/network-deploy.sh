# DEV environment
azure account set RABO-D01-CloudDelivery

# network is defined in glue resource group

azure group deployment create --template-file network.json \
    -g RG-D01-APP-ONLINEDATASTORE-003 \
    -n network-deployment
