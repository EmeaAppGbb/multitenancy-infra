using './main.bicep'

param imageVersion = 'latest'

param tenants = [
  {
    name: 'customer1'
    location: 'westeurope'
  }
  {
    name: 'customer2'
    location: 'northeurope'
  }
]
