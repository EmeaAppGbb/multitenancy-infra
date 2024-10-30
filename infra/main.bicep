targetScope = 'subscription'
param deployments array

resource resrouceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for deployment in deployments: {
    name: 'rg-${deployment.name}'
    location: deployment.location
  }
]

module resources 'modules/resources.bicep' = [
  for i in range(0, length(deployments)): {
    name: 'deployment-${deployments[i].name}'
    scope: resrouceGroup[i]
    params: {
      deployment: deployments[i]
    }
  }
]
