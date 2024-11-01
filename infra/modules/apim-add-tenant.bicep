param apimName string
param kustoName string
param kustoRg string
param tenantName string

resource service 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apimName
}

resource kustoCluster 'Microsoft.Kusto/clusters@2023-08-15' existing = {
  scope: resourceGroup(kustoRg)
  name: kustoName
}

#disable-next-line BCP081
resource subscription 'Microsoft.ApiManagement/service/subscriptions@2024-06-01-preview' = {
  parent: service
  name: tenantName
  properties: {
    displayName: tenantName
    scope: '/products/demo-apis'
  }
}

#disable-next-line BCP081
resource backend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  parent: service
  name: tenantName
  properties: {
    type: 'Single'
    protocol: 'http'
    url: kustoCluster.properties.uri
  }
}
