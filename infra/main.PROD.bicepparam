using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-dbe57eb'
param environmentName = 'prod'

param tenantList = [
  {
    name: 'realtenant'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
