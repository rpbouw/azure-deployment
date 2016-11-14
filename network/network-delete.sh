azure account set RABO-D51-CloudDelivery-Unmanaged

azure network vpn-gateway delete northeurope-vnetgateway -g RG-D51-APP-ONLINEDATASTORE-003 -q
azure network vpn-gateway delete westeurope-vnetgateway -g RG-D51-APP-ONLINEDATASTORE-003 -q

azure network public-ip delete northeurope-vnetgateway-pip -g RG-D51-APP-ONLINEDATASTORE-003 -q
azure network public-ip delete westeurope-vnetgateway-pip -g RG-D51-APP-ONLINEDATASTORE-003 -q

azure network vnet delete northeurope-vnet -g RG-D51-APP-ONLINEDATASTORE-003 -q
azure network vnet delete westeurope-vnet -g RG-D51-APP-ONLINEDATASTORE-003 -q

azure network nsg delete northeurope-nsg -g RG-D51-APP-ONLINEDATASTORE-003 -q
azure network nsg delete westeurope-nsg -g RG-D51-APP-ONLINEDATASTORE-003 -q
