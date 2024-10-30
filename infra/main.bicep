targetScope = 'subscription'

param imageVersion string
param tenants array?

var tenantList = tenants ?? loadJsonContent('tenants.json')

resource resrouceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for deployment in tenantList: {
    name: 'rg-tenant-${deployment.name}'
    location: deployment.location
  }
]

module resources 'modules/resources.bicep' = [
  for i in range(0, length(tenantList)): {
    name: 'deployment-${tenantList[i].name}'
    scope: resrouceGroup[i]
    params: {
      deployment: tenantList[i]
      imageVersion: imageVersion
    }
  }
]
