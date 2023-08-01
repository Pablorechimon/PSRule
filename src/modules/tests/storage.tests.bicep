@description('Azure region of the deployment')
param location string = resourceGroup().location
 
module test_storage_best_practices '../storageaccount_module_example.bicep' = {
  name: 'storage-deployment'
  params: {
    Region: location
    StorageAccountName: 'stateststateststatest'
    AccountAccessTier: 'Test'
    AccountAllowSharedKeyAccess: false
    AccountKind: 'Test'
    AccountSkuName: 'Test'
    SubnetResourceIdsForServiceEndpoints: [
      
    ]
  }
}
