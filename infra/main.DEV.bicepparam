using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-83cb921'
param environmentName = 'dev'

param tenants = [
  {
    name: 'customer1'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
  {
    name: 'cnsdev2'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
