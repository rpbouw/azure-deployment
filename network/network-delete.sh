azure account set RABO-D01-CloudDelivery

azure network vpn-connection delete -g RG-D01-APP-ONLINEDATASTORE-003 -q westeurope-to-northeurope-connection
azure network vpn-connection delete -g RG-D01-APP-ONLINEDATASTORE-003 -q northeurope-to-westeurope-connection

azure network vpn-gateway delete northeurope-vnetgateway -g RG-D01-APP-ONLINEDATASTORE-003 -q
azure network vpn-gateway delete westeurope-vnetgateway -g RG-D01-APP-ONLINEDATASTORE-003 -q

azure network public-ip delete northeurope-vnetgateway-pip -g RG-D01-APP-ONLINEDATASTORE-003 -q
azure network public-ip delete westeurope-vnetgateway-pip -g RG-D01-APP-ONLINEDATASTORE-003 -q

azure network vnet delete northeurope-vnet -g RG-D01-APP-ONLINEDATASTORE-003 -q
azure network vnet delete westeurope-vnet -g RG-D01-APP-ONLINEDATASTORE-003 -q

azure network nsg delete northeurope-nsg -g RG-D01-APP-ONLINEDATASTORE-003 -q
azure network nsg delete westeurope-nsg -g RG-D01-APP-ONLINEDATASTORE-003 -q
