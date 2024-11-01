using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-83cb921'
param environmentName = 'dev'

param tenantList = [
  {
    name: 'demotenant1'
    location: 'swedencentral'
    includeApp: false
    includeDataAndML: false
  }
]
