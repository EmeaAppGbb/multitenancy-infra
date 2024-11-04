using './main.bicep'
//[easyauith]param easyAuthSPSecret = az.getSecret('3e1e6407-7334-4898-bb27-b68e97a6b32e', 'cnsshared', 'easyauthsecrets', 'easyauth-aca-secret')
param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-89a8ac9'
param environmentName = 'dev'


param tenantList = [
  {
    name: 'cnstenant333'
    greetingName: 'Mega customer'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
  {
    name: 'cnstenant444'
    greetingName: 'Mega customer'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
  {
    name: 'cnstenant-madrid'
    greetingName: 'customer'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
]
