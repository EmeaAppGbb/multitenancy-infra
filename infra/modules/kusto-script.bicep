param name string
param clusterName string
param databaseName string
param scriptContent string

resource cluster 'Microsoft.Kusto/clusters@2023-08-15' existing = {
  name: clusterName
}

resource database 'Microsoft.Kusto/clusters/databases@2023-08-15' existing = {
  parent: cluster
  name: databaseName
}

resource script 'Microsoft.Kusto/clusters/databases/scripts@2023-08-15' = {
  name: name
  parent: database
  properties: {
    scriptContent: scriptContent
  }
}
