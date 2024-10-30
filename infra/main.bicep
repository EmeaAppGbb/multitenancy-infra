targetScope = 'subscription'
param tenants array
param imageVersion string

resource resrouceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for deployment in tenants: {
    name: '${deployment.name}-rg'
    location: deployment.location
  }
]

module resources 'modules/resources.bicep' = [
  for i in range(0, length(tenants)): {
    name: 'cns-${tenants[i].name}'
    scope: resrouceGroup[i]
    params: {
      deployment: tenants[i]
      imageVersion: imageVersion
    }
  }
]
