targetScope = 'subscription'

param imageVersion string
param tenantList array
param environmentName string

// [easyauth] @secure()
// param easyAuthSPSecret string
var prefix = 'cns-${environmentName}-tenant' // Must match value in Remove-Tenants.ps1

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
      //[easyauth] aadSecret: easyAuthSPSecret
      deployment: tenantList[i]
      imageVersion: imageVersion
    }
  }
]
