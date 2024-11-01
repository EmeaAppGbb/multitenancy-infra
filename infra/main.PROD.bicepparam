using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-4838810'
param environmentName = 'prod'

param tenantList = [
  {
    name: 'realtenant'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
