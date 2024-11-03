using './main.bicep'
//[easyauith]param easyAuthSPSecret = az.getSecret('3e1e6407-7334-4898-bb27-b68e97a6b32e', 'cnsshared', 'easyauthsecrets', 'easyauth-aca-secret')
param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-ea0d0f7'
param environmentName = 'dev'


param tenantList = [
  {
    name: 'cnstenant222'
    greetingName: 'super customer'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
]
