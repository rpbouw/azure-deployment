# DEV environment
deployenv=D51
# network is defined in glue resource group
networkrg=RG-$deployenv-APP-ONLINEDATASTORE-003
azure account set RABO-$deployenv-CloudDelivery-Unmanaged

azure group deployment create --template-file network.json \
    -g $networkrg \
    -n network-deployment
