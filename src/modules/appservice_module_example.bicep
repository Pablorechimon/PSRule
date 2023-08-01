@allowed([
  'eastus'
  'eastus2'
  'westus'
  'westus2'
])
param Region string = 'eastus'
param AppPlanResourceId string
//param AppPlanName string
@maxLength(60)
param AppServiceName string

@allowed([
  'api'
  'app'
  'app,linux'
  // 'functionapp'
  // 'functionapp,linux'
])
param AppServiceKind string = 'app'

@allowed(['', 'DOTNETCORE|6.0'])
@description('Sets the runtime type and version when running under Linux. For Windows types set this to \'\'')
param AppServiceLinuxFxVersion string = ''

@allowed(['', 'v4.0', 'v6.0'])
param AppServiceNetFrameworkVersion string

@maxLength(255)
param ApplicationInsightsName string
param LogAnalyticsWorkspaceId string
param LogStorageAccountResourceId string
param VnetIntegrationSubnetId string = ''
param SubnetResourceIdsForServiceEndpoints array = []

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: ApplicationInsightsName
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: AppServiceName
  location: Region
  identity: {
    type: 'SystemAssigned'
  }
  kind: AppServiceKind
  properties: {
    virtualNetworkSubnetId: !empty(VnetIntegrationSubnetId) ? VnetIntegrationSubnetId : null
    vnetRouteAllEnabled: !empty(VnetIntegrationSubnetId)
    clientCertMode: 'Optional'
    serverFarmId: AppPlanResourceId
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
        
        {
          name: 'InstrumentationEngine_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_BaseExtensions'
          value: '~1'
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: AppServiceKind == 'app,linux' ? '~3' : '~2' //if empty which means linux, set to ~3, if windows set to ~2.
        }
      ]
      httpLoggingEnabled: true
      ftpsState: 'Disabled'
      detailedErrorLoggingEnabled: false
      requestTracingEnabled: false
      webSocketsEnabled: false
      remoteDebuggingEnabled: false
      alwaysOn: true
      linuxFxVersion: AppServiceLinuxFxVersion //needed when running in linux
      netFrameworkVersion: AppServiceNetFrameworkVersion //.NET 6, .NET Framework 4.x = 'v4.0'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ipSecurityRestrictionsDefaultAction: 'Deny'
      ipSecurityRestrictions: [for subnetResourceId in SubnetResourceIdsForServiceEndpoints: {
        name: 'ServiceEndpoint Allow'
        vnetSubnetResourceId: subnetResourceId
        description: 'ServiceEndpoint Allow'
        action: 'Allow'
        priority: 100
      }]
    }
  }
  resource appServiceConfigLogs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: {
        fileSystem: {
          level: 'Error'
        }
      }
    }
  }
}


resource appServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =  {
  name: 'JmFamilySreDiagnosticSettings'
  scope: appService
  properties: {
    storageAccountId: LogStorageAccountResourceId
    workspaceId: LogAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
    ]
    metrics: [
       {
         category: 'AllMetrics'
         enabled: true
         retentionPolicy: {
           enabled: true
           days: 90
         }
       }
    ]
  }
}
