using './main.bicep'

param imageVersion = '001'

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
