
param location string = resourceGroup().location
param tenantName string

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = {
  name: 'log-analytics-workspace'
  params: {
    name: 'cns-${tenantName}-law'
    location: location
  }
}
