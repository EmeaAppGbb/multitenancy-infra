using './main.bicep'

param imageVersion = '001'

param tenants = [
  {
    name: 'dev1'
    location: 'westeurope'
  }
]
