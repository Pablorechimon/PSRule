@description('Azure region of the deployment')
param location string = resourceGroup().location
 
module test_appservice_best_practices '../appservice_module_example.bicep' = {
  name: 'app-service-deployment'
  params: {
    ApplicationInsightsName: 'Test'
    AppPlanResourceId: 'Test'
    AppServiceName: 'Test'
    AppServiceNetFrameworkVersion: 'v6.0'
    LogAnalyticsWorkspaceId: 'Test'
    LogStorageAccountResourceId: 'Test'
    AppServiceKind: 'app'
    AppServiceLinuxFxVersion: 'DOTNETCORE|6.0'
    Region: location
    SubnetResourceIdsForServiceEndpoints: [
      
    ]
    VnetIntegrationSubnetId: 'Test'
  }
}
