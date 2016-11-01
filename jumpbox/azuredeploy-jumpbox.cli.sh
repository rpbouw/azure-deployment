azure group create -n cassandraw -l "West Europe"
azure group deployment create --template-file azuredeploy-jumpbox.json -e azuredeploy-jumpbox.parameters.json -g cassandraw -n CassandraJBDeployment