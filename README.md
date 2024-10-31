# multitenancy-infra

cd infra
az bicep upgrade
az deployment sub create --location westeurope --template-file .\main.bicep --parameters .\main.DEV.bicepparam --what-if  