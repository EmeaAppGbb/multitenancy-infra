param greetingName string
param deployment object
param imageVersion string
param storageAccountName string

var prefix = deployment.name

module configurationStore 'tenantconfiguration.bicep' = {
  name: '${prefix}-conf'
  params: {
    deployment: deployment
    greetingName: greetingName
  }
}

module tenant 'tenantresources.bicep' = {
  name: '${prefix}-tenantresources'
  params: {
    deployment: deployment
    imageVersion: imageVersion
    storageAccountName: storageAccountName
  }

  dependsOn: [
    configurationStore
  ]
}
