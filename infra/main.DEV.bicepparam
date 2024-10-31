using './main.bicep'

param imageVersion = 'latest'
param isDev = true

param tenants = [
  {
    name: 'cnsdev'
    location: 'westeurope'
    includeApp: true
    includeML: true
    includeData: true
  }
]
