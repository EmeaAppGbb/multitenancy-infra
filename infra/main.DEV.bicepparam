using './main.bicep'

param imageVersion = 'latest'
param environmentName = 'dev'

param tenants = [
  {
    name: 'customer1'
    location: 'westeurope'
    includeApp: true
    includeDataAndML: true
  }
  {
    name: 'customer2'
    location: 'westeurope'
    includeApp: true
    includeDataAndML: true
  }
]
