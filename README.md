# multitenancy-infra

cd infra
az bicep upgrade
az deployment sub create --location swedencentral --template-file .\main.bicep --parameters .\main.DEV.bicepparamaz