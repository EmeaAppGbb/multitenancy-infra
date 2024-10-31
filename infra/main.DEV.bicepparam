using './main.bicep'

param imageVersion = 'latest'
param environmentName = 'dev'

param tenants = [
  {
    name: 'cnsdev'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
