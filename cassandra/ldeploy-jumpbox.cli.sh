azure account set RABO-D51-CloudDelivery
azure group deployment create --template-file azuredeploy-jumpbox.json \
     -e azuredeploy-jumpbox.parameters.json \
     -g RG-D51-APP-ONLINEDATASTORE-003 \
     -n JumpboxDeployment
