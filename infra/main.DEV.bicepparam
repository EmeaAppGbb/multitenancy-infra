using './main.bicep'
//[easyauith]param easyAuthSPSecret = az.getSecret('3e1e6407-7334-4898-bb27-b68e97a6b32e', 'cnsshared', 'easyauthsecrets', 'easyauth-aca-secret')
param imageVersion = 'cnssharedcr.azurecr.io/helloworld:sha-ae33ca7'
param environmentName = 'dev'


param tenantList = [
    {
        name: 'customertenant793'
        greetingName: 'Dear customer'
        location: 'swedencentral'
        includeApp: true
        includeDataAndML: false
    }
]
