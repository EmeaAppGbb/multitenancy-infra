using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-83cb921'
param environmentName = 'dev'

param tenants = [
  {
    name: 'cnsdev'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
