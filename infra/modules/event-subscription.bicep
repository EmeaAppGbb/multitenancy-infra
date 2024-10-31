param systemTopicName string
param subscriptionName string
param containerName string
param eventHubResourceId string

resource topic 'Microsoft.EventGrid/systemTopics@2024-06-01-preview' existing = {
  name: systemTopicName
}

resource subscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2024-06-01-preview' = {
  parent: topic
  name: subscriptionName
  properties: {
    deliveryWithResourceIdentity: {
      destination: {
        endpointType: 'EventHub'
        properties: {
          resourceId: eventHubResourceId
        }
      }
      identity: {
        type: 'SystemAssigned'
      }
    }
    eventDeliverySchema: 'EventGridSchema'
    filter: {
      subjectBeginsWith: '/blobServices/default/containers/${containerName}'
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
      enableAdvancedFilteringOnArrays: true
    }
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}

output resourceId string = subscription.id
