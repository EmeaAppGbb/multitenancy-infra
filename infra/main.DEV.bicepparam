using './main.bicep'
//[easyauith]param easyAuthSPSecret = az.getSecret('3e1e6407-7334-4898-bb27-b68e97a6b32e', 'cnsshared', 'easyauthsecrets', 'easyauth-aca-secret')
param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-ecf28de'
param environmentName = 'dev'


param tenantList = [
  {
    name: 'demotenant1'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
  {
    name: 'cnstesttenant7'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
  {
    name: 'globallyuniquetenantname'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: false
  }
]
