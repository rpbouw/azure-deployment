azure group create -n cassandra -l "West Europe"
azure group deployment create --template-file azuredeploy-jumpbox.json -e azuredeploy-jumpbox.parameters.json -g cassandra -n CassandraJBDeployment