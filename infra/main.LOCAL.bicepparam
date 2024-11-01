using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-83cb921'
param environmentName = 'local'

param tenantList = [
  {
    name: 'cnsdev'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
