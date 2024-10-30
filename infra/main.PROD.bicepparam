using './main.bicep'

param deployments = [
  {
    name: 'customer1'
    location: 'westeurope'
    imageVersion: 'latest'
  }
  {
    name: 'customer2'
    location: 'northeurope'
    imageVersion: 'latest'
  }
]
