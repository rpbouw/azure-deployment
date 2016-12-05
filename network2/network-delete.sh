deployenv=D51
networkrg=RG-$deployenv-APP-ONLINEDATASTORE-003

azure account set RABO-$deployenv-CloudDelivery-Unmanaged

azure network vpn-connection delete -g $networkrg -q westeurope-to-northeurope-connection
azure network vpn-connection delete -g $networkrg -q northeurope-to-westeurope-connection

azure network vpn-gateway delete northeurope-vnetgateway -g $networkrg -q
azure network vpn-gateway delete westeurope-vnetgateway -g $networkrg -q

azure network public-ip delete northeurope-vnetgateway-pip -g $networkrg -q
azure network public-ip delete westeurope-vnetgateway-pip -g $networkrg -q

azure network vnet delete northeurope-vnet -g $networkrg -q
azure network vnet delete westeurope-vnet -g $networkrg -q

azure network nsg delete northeurope-nsg -g $networkrg -q
azure network nsg delete westeurope-nsg -g $networkrg -q
