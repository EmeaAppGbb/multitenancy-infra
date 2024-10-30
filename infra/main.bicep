targetScope = 'subscription'
param tenants array
param imageVersion string

resource resrouceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for deployment in tenants: {
    name: 'rg-${deployment.name}'
    location: deployment.location
  }
]

module resources 'modules/resources.bicep' = [
  for i in range(0, length(tenants)): {
    name: 'deployment-${tenants[i].name}'
    scope: resrouceGroup[i]
    params: {
      deployment: tenants[i]
      imageVersion: imageVersion
    }
  }
]
