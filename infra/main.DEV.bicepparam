using './main.bicep'
//[easyauith]param easyAuthSPSecret = az.getSecret('3e1e6407-7334-4898-bb27-b68e97a6b32e', 'cnsshared', 'easyauthsecrets', 'easyauth-aca-secret')
param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-325e85e'
param environmentName = 'dev'


param tenantList = [
  {
    name: 'customertenant765'
    greetingName: 'Dear Customer'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
]
