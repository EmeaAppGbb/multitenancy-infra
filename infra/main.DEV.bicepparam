using './main.bicep'

param imageVersion = 'mcr.microsoft.com/dotnet/aspnet:8.0'
param environmentName = 'dev'

param tenants = [
  {
    name: 'cnsdev'
    location: 'swedencentral'
    includeApp: true
    includeDataAndML: true
  }
]
