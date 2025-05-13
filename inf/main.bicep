// File: c:\Code\no-as-a-service\inf\main.bicep

param location string = resourceGroup().location
param environmentName string = 'myContainerEnv'
param containerAppName string = 'myApiApp'
param containerImage string = 'myregistry.azurecr.io/myapi:latest'
param containerPort int = 80

resource containerApp 'Microsoft.App/containerApps@2023-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: managedEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          name: 'app'
          image: containerImage
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
        }
      ]
    }
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-04-01' = {
  name: '${environmentName}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

var logAnalyticsCustomerId = logAnalytics.properties.customerId
var logAnalyticsSharedKey = logAnalytics.listKeys().primarySharedKey

resource managedEnv 'Microsoft.App/managedEnvironments@2023-03-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
    zoneRedundant: false
  }
}
