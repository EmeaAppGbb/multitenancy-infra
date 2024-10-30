param deployment object
param imageVersion string

var nameInfix = deployment.name
var location = deployment.location
var containerImage = concat('mcr.microsoft.com/azuredocs/containerapps-helloworld:', imageVersion)

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = {
  name: '${nameInfix}-log-analytics-workspace'
  params: {
    name: 'log-${nameInfix}-01'
    location: location
  }
}

module containerEnvironment 'br/public:avm/res/app/managed-environment:0.8.0' = {
  name: '${nameInfix}-managed-environment'
  params: {
    name: 'cae-${nameInfix}-01'
    location: location
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    zoneRedundant: false
  }
}

module contianerApp 'br/public:avm/res/app/container-app:0.9.0' = {
  name: '${nameInfix}-container-app'
  params: {
    name: 'ca-${nameInfix}-01'
    location: location
    environmentResourceId: containerEnvironment.outputs.resourceId
    containers: [
      {
        image: '${containerImage}:${deployment.imageVersion}'
        name: 'app'
        resources: {
          cpu: '0.25'
          memory: '0.5Gi'
        }
      }
    ]
  }
}
