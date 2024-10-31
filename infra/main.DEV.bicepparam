using './main.bicep'

param imageVersion = 'latest'
param environmentName = 'dev'

param tenants = [
  {
    name: 'cnsdev'
    location: 'westeurope'
    includeApp: true
    includeML: true
    includeData: true
  }
]
