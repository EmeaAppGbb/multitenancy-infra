param deployment object
param imageVersion string

var prefix = deployment.name
var location = deployment.location
var containerImage = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:${imageVersion}'

var apimResourceGroup = 'cnsshared'
var apimName = 'cnsshared-apim'

// Resource type abbreviations: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

//
// Shared
//
resource apim 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apimName
  scope: resourceGroup(apimResourceGroup)
}

//
// Common
//
module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = {
  name: '${prefix}-log'
  params: {
    name: '${prefix}-log'
    location: location
  }
}

module applicationInsights 'br/public:avm/res/insights/component:0.4.1' = {
  name: '${prefix}-app-insights'
  params: {
    name: '${prefix}-appi'
    location: location
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
  }
}

module keyVault 'br/public:avm/res/key-vault/vault:0.9.0' = {
  name: '${prefix}-key-vault'
  params: {
    name: '${prefix}-kv'
    location: location
    enablePurgeProtection: false
    softDeleteRetentionInDays: 7
  }
}

//
// App
//
module configurationStore 'br/public:avm/res/app-configuration/configuration-store:0.5.1' = if (deployment.includeApp) {
  name: '${prefix}-configuratio-store'
  params: {
    name: '${prefix}-appcs'
    enablePurgeProtection: false
    location: location
    disableLocalAuth: false
    softDeleteRetentionInDays: 1
  }
}

module containerEnvironment 'br/public:avm/res/app/managed-environment:0.8.0' = if (deployment.includeApp) {
  name: '${prefix}-managed-environment'
  params: {
    name: '${prefix}-cae'
    location: location
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    zoneRedundant: false
  }
}

module contianerApp 'br/public:avm/res/app/container-app:0.9.0' = if (deployment.includeApp) {
  name: '${prefix}-container-app'
  params: {
    name: '${prefix}-ca'
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

//
// ML
// 
module mlStorageAccount 'br/public:avm/res/storage/storage-account:0.9.1' = {
  name: '${prefix}-ml-storage-account'
  params: {
    name: '${prefix}stml'
    location: location
    publicNetworkAccess: 'Enabled'
    isLocalUserEnabled: true
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

module containerRegistry 'br/public:avm/res/container-registry/registry:0.5.1' = {
  name: '${prefix}-container-registry'
  params: {
    #disable-next-line BCP334
    name: '${prefix}crml'
    location: location
    publicNetworkAccess: 'Enabled'
    acrAdminUserEnabled: true
  }
}

module mlWorkspace 'br/public:avm/res/machine-learning-services/workspace:0.8.2' = if (deployment.includeML) {
  name: '${prefix}-ml-workspace'
  params: {
    name: '${prefix}-mlw'
    location: location
    sku: 'Basic'
    associatedKeyVaultResourceId: keyVault.outputs.resourceId
    associatedApplicationInsightsResourceId: applicationInsights.outputs.resourceId
    associatedContainerRegistryResourceId: containerRegistry.outputs.resourceId
    associatedStorageAccountResourceId: mlStorageAccount.outputs.resourceId
    publicNetworkAccess: 'Enabled'
  }
}

//
// Data
//
module eventHub 'br/public:avm/res/event-hub/namespace:0.7.1' = if (deployment.includeData) {
  name: '${prefix}-event-hub'
  params: {
    name: '${prefix}-evhns'
    location: location
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    eventhubs: [
      {
        name: 'SucceededIngestion'
        partitionCount: 1
      }
    ]
  }
}

module kusto 'br/public:avm/res/kusto/cluster:0.3.2' = if (deployment.includeData) {
  name: '${prefix}-kusto'
  params: {
    name: '${prefix}-dec'
    location: location
    sku: 'Dev(No SLA)_Standard_D11_v2'
    tier: 'Basic'
    capacity: 1
    enablePublicNetworkAccess: true
    enablePurge: false
    enableZoneRedundant: false
    enableRestrictOutboundNetworkAccess: false
  }
}

module database 'modules/kusto-database.bicep' = if (deployment.includeData) {
  name: '${prefix}-kusto-database'
  params: {
    name: 'LogDatabase'
    location: location
    clusterName: kusto.outputs.name
  }
}

module tables 'modules/kusto-script.bicep' = if (deployment.includeData) {
  name: '${prefix}-kusto-tables'
  params: {
    clusterName: kusto.outputs.name
    databaseName: database.outputs.name
    name: 'tables'
    scriptContent: '''
        .create table SucceededIngestion (records:dynamic)
      '''
  }
}

module eventGridConnection1 'modules/kusto-eventhub-connection.bicep' = if (deployment.includeData) {
  name: '${prefix}-event-grid-connection1'
  params: {
    name: 'SucceededIngestion'
    location: location
    clusterName: kusto.outputs.name
    databaseName: database.outputs.name
    tableName: 'SucceededIngestion'
    eventHubNamespace: eventHub.outputs.name
    eventHub: 'SucceededIngestion'
  }
  dependsOn: [
    tables
  ]
}
