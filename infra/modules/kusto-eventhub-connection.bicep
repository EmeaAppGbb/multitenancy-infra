param name string
param location string
param eventHubNamespace string
param eventHub string
param tableName string
param clusterName string
param databaseName string

resource cluster 'Microsoft.Kusto/clusters@2023-08-15' existing = {
  name: clusterName
}

resource database 'Microsoft.Kusto/clusters/databases@2023-08-15' existing = {
  parent: cluster
  name: databaseName
}
resource dataConnection 'Microsoft.Kusto/clusters/databases/dataConnections@2023-08-15' = {
  name: name
  location: location
  parent: database
  kind: 'EventHub'
  properties: {
    consumerGroup: '$Default'
    eventHubResourceId: resourceId('Microsoft.EventHub/namespaces/eventhubs', eventHubNamespace, eventHub)
    tableName: tableName
    dataFormat: 'JSON'
  }
}

output name string = dataConnection.name
