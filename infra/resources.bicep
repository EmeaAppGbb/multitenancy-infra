param deployment object
param imageVersion string

var prefix = deployment.name
var location = deployment.location

var sharedResourceGroup = 'cnsshared'
var crName = 'cnssharedcr'
var adpimResrouceGroup = 'customertenant001adx'
var apimName = 'customertenant001APIM'
var landingContainerName = 'landing'
var demoGroupId = '8691cafd-ff9e-4817-98b4-2ef749b2b041' // DemoDataApp-GitOps
var apimClientId = 'cd4f6b8d-7d8e-4742-8ae7-3d38038c186b'

// Resource type abbreviations: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

//
// Shared
//
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: crName
  scope: resourceGroup(sharedResourceGroup)
}

//
// Common
//
module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = {
  name: '${prefix}-log'
  params: {
    name: '${prefix}-log'
    location: location
    dataExports: deployment.includeDataAndML
      ? [
          {
            destination: {
              metaData: {
                eventHubName: 'SucceededIngestion'
              }
              resourceId: eventHubNamespace.outputs.resourceId
            }
            enable: true
            name: 'SucceededIngestion'
            tableNames: [
              'SucceededIngestion'
            ]
          }
          {
            destination: {
              metaData: {
                eventHubName: 'FailedIngestion'
              }
              resourceId: eventHubNamespace.outputs.resourceId
            }
            enable: true
            name: 'FailedIngestion'
            tableNames: [
              'FailedIngestion'
            ]
          }
          {
            destination: {
              metaData: {
                eventHubName: 'IngestionBatching'
              }
              resourceId: eventHubNamespace.outputs.resourceId
            }
            enable: true
            name: 'IngestionBatching'
            tableNames: [
              'ADXIngestionBatching'
            ]
          }
        ]
      : []
  }
}

//
// App
//
module configurationStore 'br/public:avm/res/app-configuration/configuration-store:0.5.1' = if (deployment.includeApp) {
  name: '${prefix}-configuration-store'
  params: {
    name: '${prefix}-appcs'
    enablePurgeProtection: false
    location: location
    disableLocalAuth: false
    softDeleteRetentionInDays: 1
    keyValues:[
      {
        name: 'HelloWorldApp:Settings:Sentinel'
        value: '1'
      }
      {
        name: 'HelloWorldApp:Settings:GreetingConfiguration'
        value: 'CNS'
      }
    ]
  }
}

module containerEnvironment 'br/public:avm/res/app/managed-environment:0.8.0' = if (deployment.includeApp) {
  name: '${prefix}-managed-environment'
  params: {
    name: '${prefix}-cae'
    location: location
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    zoneRedundant: false
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

module containerApp 'br/public:avm/res/app/container-app:0.9.0' = if (deployment.includeApp) {
  name: '${prefix}-container-app'
  params: {
    name: '${prefix}-ca'
    location: location
    environmentResourceId: containerEnvironment.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        identity.outputs.resourceId
      ]
    }
    registries: [
      {
        server: containerRegistry.properties.loginServer
        identity: identity.outputs.resourceId
      }
    ]
    containers: [
      {
        image: imageVersion
        name: 'app'
        resources: {
          cpu: '0.25'
          memory: '0.5Gi'
        }
        env: [
          {
            name: 'AppConfig__Endpoint'
            value: configurationStore.outputs.endpoint
          }
        ]
      }
    ]
  }
}

module identity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = if (deployment.includeApp) {
  name: 'admin-app-identity'
  params: {
    name: '${prefix}-id'
    location: location
  }
}

module roleAssignment1 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (deployment.includeApp) {
  name: '${prefix}-role-assignment-1'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    resourceId: containerRegistry.id
    principalId: identity.outputs.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    roleName: 'Contributor'
  }
}

module roleAssignment6 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (deployment.includeApp) {
  name: '${prefix}-role-assignment-6'
  params: {
    resourceId: configurationStore.outputs.resourceId
    principalId: containerApp.outputs.systemAssignedMIPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    roleName: 'App Configuration Data Owner'
  }
}

//
// Data & ML
// 
module applicationInsights 'br/public:avm/res/insights/component:0.4.1' = if (deployment.includeDataAndML) {
  name: '${prefix}-app-insights'
  params: {
    name: '${prefix}-appi'
    location: location
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
  }
}

module keyVault 'br/public:avm/res/key-vault/vault:0.9.0' = if (deployment.includeDataAndML) {
  name: '${prefix}-key-vault'
  params: {
    name: '${prefix}-kv'
    location: location
    enablePurgeProtection: false
    softDeleteRetentionInDays: 7
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.9.1' = if (deployment.includeDataAndML) {
  name: '${prefix}-storage-account'
  params: {
    name: '${prefix}st'
    location: location
    publicNetworkAccess: 'Enabled'
    isLocalUserEnabled: true
    enableHierarchicalNamespace: true
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    blobServices: {
      containers: [
        {
          name: landingContainerName
          publicAccess: 'None'
        }
      ]
    }
  }
}

module mlStorageAccount 'br/public:avm/res/storage/storage-account:0.9.1' = if (deployment.includeDataAndML) {
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

module mlWorkspace 'br/public:avm/res/machine-learning-services/workspace:0.8.2' = if (deployment.includeDataAndML) {
  name: '${prefix}-ml-workspace'
  params: {
    name: '${prefix}-mlw'
    location: location
    sku: 'Basic'
    associatedKeyVaultResourceId: keyVault.outputs.resourceId
    associatedApplicationInsightsResourceId: applicationInsights.outputs.resourceId
    associatedContainerRegistryResourceId: containerRegistry.id
    associatedStorageAccountResourceId: mlStorageAccount.outputs.resourceId
    publicNetworkAccess: 'Enabled'
    managedIdentities: {
      systemAssigned: true
    }
  }
}

module roleAssignment2 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (deployment.includeDataAndML) {
  name: '${prefix}-role-assignment-2'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    resourceId: containerRegistry.id
    principalId: mlWorkspace.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    roleName: 'AcrPull'
  }
}

module eventHubNamespace 'br/public:avm/res/event-hub/namespace:0.7.1' = if (deployment.includeDataAndML) {
  name: '${prefix}-event-hub'
  params: {
    name: '${prefix}-evhns'
    location: location
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    skuName: 'Standard'

    eventhubs: [
      {
        name: 'StorageHub'
      }
      {
        name: 'SucceededIngestion'
      }
      {
        name: 'FailedIngestion'
      }
      {
        name: 'IngestionBatching'
      }
    ]
  }
}

module eventGridTopic 'br/public:avm/res/event-grid/system-topic:0.4.0' = if (deployment.includeDataAndML) {
  name: '${prefix}-event-grid'
  params: {
    name: '${prefix}-egst'
    location: location
    managedIdentities: {
      systemAssigned: true
    }
    source: storageAccount.outputs.resourceId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

module eventSubscription 'modules/event-subscription.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-event-subscription'
  params: {
    systemTopicName: eventGridTopic.outputs.name
    subscriptionName: 'BlobSubscription'
    containerName: landingContainerName
    eventHubResourceId: eventHubNamespace.outputs.eventHubResourceIds[0]
  }
  dependsOn: [
    roleAssignment5
  ]
}

module kusto 'br/public:avm/res/kusto/cluster:0.3.2' = if (deployment.includeDataAndML) {
  name: '${prefix}-kusto'
  params: {
    name: '${prefix}-dec'
    location: location
    sku: 'Standard_D12_v2'
    tier: 'Standard'
    capacity: 2
    enablePublicNetworkAccess: true
    enablePurge: false
    enableZoneRedundant: false
    enableRestrictOutboundNetworkAccess: false
    enableStreamingIngest: true
    managedIdentities: {
      systemAssigned: true
    }
    principalAssignments: [
      {
        principalId: mlWorkspace.outputs.systemAssignedMIPrincipalId
        principalType: 'App'
        role: 'AllDatabasesAdmin'
      }
      {
        principalId: demoGroupId
        principalType: 'Group'
        role: 'AllDatabasesAdmin'
      }
      {
        principalId: apimClientId
        principalType: 'App'
        role: 'AllDatabasesViewer'
      }
    ]
    diagnosticSettings: [
      {
        name: 'LogAnalytics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

module apimConfig 'modules/apim-add-tenant.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-apim-config'
  scope: resourceGroup(adpimResrouceGroup)
  params: {
    apimName: apimName
    kustoName: kusto.outputs.name
    kustoRg: resourceGroup().name
    tenantName: deployment.name
  }
}

module logDatabase 'modules/kusto-database.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-kusto-log-database'
  params: {
    name: 'LogDatabase'
    location: location
    clusterName: kusto.outputs.name
  }
}

module demoDatabase 'modules/kusto-database.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-kusto-demo-database'
  params: {
    name: 'DemoDatabase'
    location: location
    clusterName: kusto.outputs.name
  }
}

module logTables 'modules/kusto-script.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-kusto-log-tables'
  params: {
    clusterName: kusto.outputs.name
    databaseName: logDatabase.outputs.name
    name: 'tables'
    scriptContent: loadTextContent('log-db-script.kql')
  }
}

module demoTables 'modules/kusto-script.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-kusto-demo-tables'
  params: {
    clusterName: kusto.outputs.name
    databaseName: demoDatabase.outputs.name
    name: 'tables'
    scriptContent: loadTextContent('demo-db-script.kql')
  }
}

module eventHubConnection1 'modules/kusto-eventhub-connection.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-event-hub-connection1'
  params: {
    name: 'SucceededIngestion'
    location: location
    clusterName: kusto.outputs.name
    databaseName: logDatabase.outputs.name
    tableName: 'SucceededIngestion'
    eventHubNamespace: eventHubNamespace.outputs.name
    eventHub: 'SucceededIngestion'
  }
  dependsOn: [
    logTables
  ]
}

module eventHubConnection2 'modules/kusto-eventhub-connection.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-event-hub-connection2'
  params: {
    name: 'FailedIngestion'
    location: location
    clusterName: kusto.outputs.name
    databaseName: logDatabase.outputs.name
    tableName: 'FailedIngestion'
    eventHubNamespace: eventHubNamespace.outputs.name
    eventHub: 'FailedIngestion'
  }
  dependsOn: [
    logTables
  ]
}

module eventHubConnection3 'modules/kusto-eventhub-connection.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-event-hub-connection3'
  params: {
    name: 'IngestionBatching'
    location: location
    clusterName: kusto.outputs.name
    databaseName: logDatabase.outputs.name
    tableName: 'IngestionBatching'
    eventHubNamespace: eventHubNamespace.outputs.name
    eventHub: 'IngestionBatching'
  }
  dependsOn: [
    logTables
  ]
}

module eventGridConnection1 'modules/kusto-eventgrid-connection.bicep' = if (deployment.includeDataAndML) {
  name: '${prefix}-event-grid-connection1'
  params: {
    name: 'CustomerData'
    location: location
    clusterName: kusto.outputs.name
    databaseName: demoDatabase.outputs.name
    tableName: 'CustomerData'
    eventGridResourceId: eventSubscription.outputs.resourceId
    eventHubResourceId: eventHubNamespace.outputs.eventHubResourceIds[0]
    storageAccocuntResourceId: storageAccount.outputs.resourceId
  }
  dependsOn: [
    logTables
  ]
}

module roleAssignment3 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (deployment.includeDataAndML) {
  name: '${prefix}-role-assignment-3'
  params: {
    resourceId: eventHubNamespace.outputs.resourceId
    principalId: kusto.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
    roleName: 'Azure Event Hubs Data Receiver'
  }
}

module roleAssignment4 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (deployment.includeDataAndML) {
  name: '${prefix}-role-assignment-4'
  params: {
    resourceId: storageAccount.outputs.resourceId
    principalId: kusto.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleName: 'Storage Blob Data Contributor'
  }
}

module roleAssignment5 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (deployment.includeDataAndML) {
  name: '${prefix}-role-assignment-5'
  params: {
    resourceId: eventHubNamespace.outputs.resourceId
    principalId: eventGridTopic.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: '2b629674-e913-4c01-ae53-ef4638d8f975'
    roleName: 'Azure Event Hubs Data Sender'
  }
}
