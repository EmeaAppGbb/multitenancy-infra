param deployment object
param imageVersion string

var prefix = deployment.name
var location = deployment.location
var containerImage = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:${imageVersion}'

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = {
  name: '${prefix}-law'
  params: {
    name: '${prefix}-la'
    location: location
  }
}

module containerEnvironment 'br/public:avm/res/app/managed-environment:0.8.0' = {
  name: '${prefix}-managed-environment'
  params: {
    name: '${prefix}-cae'
    location: location
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    zoneRedundant: false
  }
}

module contianerApp 'br/public:avm/res/app/container-app:0.9.0' = {
  name: '${prefix}-container-app'
  params: {
    name: '${prefix}-app'
    location: location
    environmentResourceId: containerEnvironment.outputs.resourceId
    containers: [
      {
        image: containerImage
        name: 'app'
        resources: {
          cpu: '0.25'
          memory: '0.5Gi'
        }
      }
    ]
  }
}
