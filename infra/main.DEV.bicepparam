using './main.bicep'

param deployments = [
  {
    name: 'dev1'
    location: 'westeurope'
    imageVersion: 'latest'
  }
]
