var prefix = 'cnsshared'
var location = 'westeurope'

module containerRegistry 'br/public:avm/res/container-registry/registry:0.5.1' = {
  name: 'container-registry'
  params: {
    #disable-next-line BCP334
    name: '${prefix}cr'
    location: location
    publicNetworkAccess: 'Enabled'
    acrAdminUserEnabled: true
  }
}

module apim 'br/public:avm/res/api-management/service:0.6.0' = {
  name: 'api-management'
  params: {
    name: '${prefix}-apim'
    location: location
    publisherEmail: 'admin@example.com'
    publisherName: 'CNS'
    sku: 'Developer'
  }
}
