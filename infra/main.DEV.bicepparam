using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-5256e13'
param environmentName = 'dev'

param tenantList = [
  {
    name: 'demotenant1'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
]
