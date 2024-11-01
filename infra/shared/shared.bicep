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
