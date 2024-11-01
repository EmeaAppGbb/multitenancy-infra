param containerAppName string
param aadClientId string
param aadTenantId string

resource containerApp 'Microsoft.App/containerApps@2024-03-01' existing = {
  name: containerAppName
}

resource azureAdAuth 'Microsoft.App/containerApps/authConfigs@2024-03-01' = {
  name: 'current'
  parent: containerApp
  properties: {
    globalValidation: {
      unauthenticatedClientAction: 'RedirectToLoginPage'
       redirectToProvider: 'azureactivedirectory'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId:  aadClientId
          clientSecretSettingName: 'microsoft-provider-authentication-secret'
          openIdIssuer: 'https://sts.windows.net/${aadTenantId}/v2.0'
        }
        validation: {
          allowedAudiences: [
            'api://${aadClientId}'
          ]
        }
      }
    }
    login: {
      preserveUrlFragmentsForLogins: false
    }
    platform: {
      enabled: true
    }
  }
}
