targetScope = 'subscription'

param imageVersion string
param tenants array?
param isDev bool = false

var tenantList = tenants ?? loadJsonContent('tenants.json')
var prefix = isDev ? 'cns' : 'cns-tenant' // Must match value in Remove-Tenants.ps1

resource resrouceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for deployment in tenantList: {
    name: '${prefix}-${deployment.name}'
    location: deployment.location
  }
]

module resources 'resources.bicep' = [
  for i in range(0, length(tenantList)): {
    name: '${prefix}-${tenantList[i].name}'
    scope: resrouceGroup[i]
    params: {
      deployment: tenantList[i]
      imageVersion: imageVersion
    }
  }
]
