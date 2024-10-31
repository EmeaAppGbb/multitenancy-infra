param name string
param location string
param eventGridResourceId string
param storageAccocuntResourceId string
param consumerGroup string
param clusterName string
param databaseName string
param tableName string

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
  kind: 'EventGrid'
  properties: {
    eventGridResourceId: eventGridResourceId
    storageAccountResourceId: storageAccocuntResourceId
    consumerGroup: consumerGroup
    tableName: tableName
    dataFormat: 'CSV'
  }
}

output name string = dataConnection.name