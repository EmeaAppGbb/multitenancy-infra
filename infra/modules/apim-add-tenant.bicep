param apimName string
param kustoName string
param kustoRg string
param tenantName string

resource service 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apimName
}

resource kustoCluster 'Microsoft.Kusto/clusters@2023-08-15' existing = {
  scope: resourceGroup(kustoRg)
  name: kustoName
}

resource subscription 'Microsoft.ApiManagement/service/subscriptions@2022-08-01' = {
  parent: service
  name: 'sub-${tenantName}'
  properties: {
    displayName: 'sub-${tenantName}'
    scope: '/products/demo-apis'
  }
}

resource backend 'Microsoft.ApiManagement/service/backends@2024-05-01' = {
  parent: service
  name: tenantName
  properties: {
    type: 'Single'
    protocol: 'http'
    url: kustoCluster.properties.uri
  }
}
