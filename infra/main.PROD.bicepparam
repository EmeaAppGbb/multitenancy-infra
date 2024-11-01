using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-83cb921'
param environmentName = 'prod'

param tenantList = [
  {
    name: 'customer1'
    location: 'swedencentral'
    includeApp: false
    includeDataAndML: false
  }
]
