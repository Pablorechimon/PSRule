@allowed([
  'eastus'
  'eastus2'
  'westus'
  'westus2'
])
param Region string = 'eastus'

@maxLength(40)
param AppPlanName string

@allowed([
  'D1' //Shared (Dev/Test only)
  'F1' //Free (Dev/Test only)
  'B1' //Basic (Dev/Test only) - Capacity Min 1 Max 3
  'B2' //Basic (Dev/Test only) - Capacity Min 1 Max 3
  'B3' //Basic (Dev/Test only) - Capacity Min 1 Max 3
  'S1' //Standard - Capacity Min 1 Max 10
  'S2' //Standard - Capacity Min 1 Max 10
  'S3' //Standard - Capacity Min 1 Max 10
  'P1' //Premium - Capacity Min 1 Max 20
  'P2' //Premium - Capacity Min 1 Max 20
  'P3' //Premium - Capacity Min 1 Max 20
  'P1v2' //PremiumV2 - Capacity Min 1 Max 30
  'P2v2' //PremiumV2 - Capacity Min 1 Max 30
  'P3v2' //PremiumV2 - Capacity Min 1 Max 30
  'P1v3' //PremiumV3 - Capacity Min 1 Max 30
  'P2v3' //PremiumV3 - Capacity Min 1 Max 30
  'P3v3' //PremiumV3 - Capacity Min 1 Max 30
  'EP1' //ElasticPremium - Capacity Min 1 Max 20
  'EP2' //ElasticPremium - Capacity Min 1 Max 20
  'EP3' //ElasticPremium - Capacity Min 1 Max 20
  'WS1' //WorkflowStandard - Capacity Min 1 Max 20
  'WS2' //WorkflowStandard - Capacity Min 1 Max 20
  'WS3' //WorkflowStandard - Capacity Min 1 Max 20
  // 'EI1' //ElasticIsolated - Capacity Min 1 Max 20
  // 'EI2' //ElasticIsolated - Capacity Min 1 Max 20
  // 'EI3' //ElasticIsolated - Capacity Min 1 Max 20
])
param AppPlanSku string = 'S1'
param AppPlanCapacity int = 1
param AppPlanZoneRedundant bool = true


@allowed(['',  'linux'])
@description('Sets the Kind property. Valid values are \'\' for Windows, and \'linux\' for Linux.')
param AppPlanKind string = ''

@description('In order to properly set the App Plan type to Linux, Reserved must be true.')
param AppPlanReserved bool = AppPlanKind == 'linux' ? true : false


resource appPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: AppPlanName
  location: Region
  properties: {
    zoneRedundant: AppPlanZoneRedundant
    reserved: AppPlanReserved
  }
  sku: {
    name: AppPlanSku
    capacity: AppPlanCapacity
  }
  kind: AppPlanKind
}


output AppPlanResourceId string = appPlan.id
