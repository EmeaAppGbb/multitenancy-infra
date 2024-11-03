using './main.bicep'

//[easyauith] param easyAuthSPSecret = az.getSecret('3e1e6407-7334-4898-bb27-b68e97a6b32e', 'cnsshared', 'easyauthsecrets ', 'easyauth-aca-secret', '21fc06505d0f4055b50500b9361baad1')
param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-ea0d0f7'
param environmentName = 'prod'

param tenantList = [
  {
    name: 'realtenant'
    greetingName: 'Customer'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
