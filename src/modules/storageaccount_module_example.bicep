@allowed([
  'eastus'
  'eastus2'
  'westus'
  'westus2'
])
param Region string = 'eastus'

@maxLength(24)
param StorageAccountName string
param AccountKind string = 'StorageV2'
param AccountSkuName string = 'Standard_ZRS'
param AccountAccessTier string = 'Hot'
param AccountAllowSharedKeyAccess bool = false
param SubnetResourceIdsForServiceEndpoints array = []

// @allowed([
//   'Allow'
//   'Deny'
// ])
// @description('Deny means "Enabled from selected virtual networks and IP addresses only".')
// param NetworkAclsDefaultAction string = 'Deny'


// @allowed([
//   'Enabled'
//   'Disabled'
// ])
// @description('Disabled means completely restrict the public endpoint which disallows traffic from Service Endpoints.')
// param publicNetworkAccess string = 'Disabled'

//Service Endpoint Config for Storage Account to allow Logic App to communicate with it privately.
var virtualNetworkRules = [for resourceId in SubnetResourceIdsForServiceEndpoints: { action: 'Allow', id: resourceId }]
var publicNetworkAccess = length(virtualNetworkRules) > 0 ? 'Enabled' : 'Disabled'


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: StorageAccountName
  location: Region
  kind: AccountKind
  sku: {
    name: AccountSkuName
  }
  properties: {
    accessTier: AccountAccessTier
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: AccountAllowSharedKeyAccess
    allowCrossTenantReplication: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowedCopyScope: 'AAD'
    publicNetworkAccess: publicNetworkAccess //Set to disabled by default, enabled if we have Service Endpoints.
    isLocalUserEnabled: false 
    encryption: {
      requireInfrastructureEncryption: true
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
      }
    }

    networkAcls: {
      bypass: 'None' //'Logging, Metrics, AzureServices'
      defaultAction: 'Deny' //NetworkAclsDefaultAction
      //Service Endpoints
      virtualNetworkRules: !empty(SubnetResourceIdsForServiceEndpoints) ? virtualNetworkRules : []
    }
  }

}



resource advancedThreatProtectionSettings 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
  scope: storageAccount
  name: 'current'
  properties: {
    isEnabled: true
  }
}

output StorageAccountName string = storageAccount.name
output StorageAccountResourceId string = storageAccount.id

