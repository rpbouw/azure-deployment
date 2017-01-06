# DEV environment
azure account set RABO-D51-CloudDelivery-Unmanaged
RG_NETWORK=RG-D51-APP-ONLINEDATASTORE-003
SHARED_KEY=osaidu2j2j2k33lk488dajsadndazxqw328909754jjkkdndckdkododjsjnqazxsfjngtb7363m

mkdir tmp-westeurope-to-northeurope-connection
cd tmp-westeurope-to-northeurope-connection
nohup azure network vpn-connection create \
     -g $RG_NETWORK \
     -n westeurope-to-northeurope-connection \
     -l westeurope \
     --vnet-gateway1 westeurope-vnetgateway \
     --vnet-gateway1-group $RG_NETWORK \
     --vnet-gateway2 northeurope-vnetgateway \
     --vnet-gateway2-group $RG_NETWORK \
     --type Vnet2Vnet \
     --routing-weight 0 \
     --shared-key $SHARED_KEY &

cd ..
mkdir tmp-northeurope-to-westeurope-connection
cd tmp-northeurope-to-westeurope-connection
nohup azure network vpn-connection create \
     -g $RG_NETWORK \
     -n northeurope-to-westeurope-connection \
     -l northeurope \
     --vnet-gateway1 northeurope-vnetgateway \
     --vnet-gateway1-group $RG_NETWORK \
     --vnet-gateway2 westeurope-vnetgateway \
     --vnet-gateway2-group $RG_NETWORK \
     --type Vnet2Vnet \
     --routing-weight 0 \
     --shared-key $SHARED_KEY &

cd ..