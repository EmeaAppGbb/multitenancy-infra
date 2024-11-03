# multitenancy-infra

[![Reconciliation](https://github.com/EmeaAppGbb/multitenancy-infra/actions/workflows/ci.yml/badge.svg)](https://github.com/EmeaAppGbb/multitenancy-infra/actions/workflows/ci.yml)


cd infra
az bicep upgrade
az deployment sub create --location westeurope --template-file .\main.bicep --parameters .\main.DEV.bicepparam --what-if  