param name string
param location string
param clusterName string

resource cluster 'Microsoft.Kusto/clusters@2023-08-15' existing = {
  name: clusterName
}

resource database 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  name: name
  location: location
  kind: 'ReadWrite'
  parent: cluster
}

output name string = database.name
