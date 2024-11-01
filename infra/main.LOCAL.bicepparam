using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-83cb921'
param environmentName = 'local'

param tenants = [
  {
    name: 'cnsdev5'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
