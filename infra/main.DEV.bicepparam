using './main.bicep'

param imageVersion = 'latest'

param tenants = [
  {
    name: 'dev1'
    location: 'westeurope'
  }
]
