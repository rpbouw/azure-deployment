# Setup Linux Dynamic data disks 
## A great Control Machine for All your Azure Automation Needs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frpbouw%2Fazure-deployment%2Fmaster%2Fazuredeploy.json" target="_blank">
   <img alt="Deploy to Azure" src="http://azuredeploy.net/deploybutton.png"/>
</a>

  <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Frpbouw%2Fazure-deployment%2Fmaster%2Fazuredeploy.json" target="_blank">  
<img src="http://armviz.io/visualizebutton.png"/> </a>  

### This creates configurable number of disks with configurable size for centos
* Disk auto mounting is at /'parameter'/data.
* NFS4 is on on the above.
* Strict ssh public key enabled.
* Nodes that share public RSA key shared can be used as direct jump boxes as azureuser@DNS.
* NSG is required.
* Internal firewalld is off.
* gcc and other necessary software available for Plain CentOS 6.5/6.6/7.1/7.2 and for Ubuntu 16.04.0-LTS
* WALinuxAgent updates are disabled on first deployment.
