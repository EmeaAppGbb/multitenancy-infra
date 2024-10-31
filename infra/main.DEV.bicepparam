using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-0d4f876'
param environmentName = 'dev'

param tenants = [
  {
    name: 'cnsdev'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
