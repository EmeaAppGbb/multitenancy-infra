using './main.bicep'
param easyAuthSPSecret = az.getSecret('3e1e6407-7334-4898-bb27-b68e97a6b32e', 'cnsshared', 'easyauthsecrets ', 'easyauth-aca-secret', '21fc06505d0f4055b50500b9361baad1')
param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-dbe57eb'
param environmentName = 'dev'


param tenantList = [
  {
    name: 'demotenant1'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
]
