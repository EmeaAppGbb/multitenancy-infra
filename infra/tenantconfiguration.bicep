param deployment object
param greetingName string

var prefix = deployment.name
var location = deployment.location

module configurationStore 'br/public:avm/res/app-configuration/configuration-store:0.5.1' = if (deployment.includeApp) {
  name: '${prefix}-app-configuration-store'
  params: {
    name: '${prefix}-appcs'
    enablePurgeProtection: false
    location: location
    disableLocalAuth: false
    softDeleteRetentionInDays: 1
    keyValues:[
      {
        name: 'Sentinel'
        value: '1'
      }
      {
        name: 'GreetingConfiguration'
        value: greetingName
      }
    ]
  }
}
