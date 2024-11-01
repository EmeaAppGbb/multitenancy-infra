using './main.bicep'

param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-dbe57eb'
param environmentName = 'dev'

param tenantList = [
  {
    name: 'demotenant1'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
]
