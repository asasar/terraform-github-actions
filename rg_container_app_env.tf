########################################
# Resource Group: Shared GenAI Services
########################################
module "ResourceGroupContainerAppEnvSyhunt0001" {
  source = "../../../Modules/terraform/azurerm/ResourceGroup"

  namingConvention = var.namingConvention
  tierCode         = "sha"
  location         = var.location
  region           = var.region
  increment        = "0001"

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Resources Group for Container App Environment for ${var.tierTag}",
  }
}


########################################
# Container App Environment
########################################
module "ContainerAppEnvironmentShared0000" {
  source = "../../../Modules/terraform/azurerm/ContainerAppsEnvironment"

  namingConvention                      = var.namingConvention
  tierCode                              = "sha"
  location                              = var.location
  region                                = var.region
  increment                             = "0001"
  incrementResourceGroupContainerAppEnv = "0002"
  resourceGroupName                     = module.ResourceGroupContainerAppEnvSyhunt0001.ResourceGroupName
  logAnalyticsWorkspaceID               = var.logAnalyticsWorkspaceID
  zoneRedundancyEnabled                 = false

  infrastructureSubnetID       = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.ResourceGroupShared0000.ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${module.VirtualNetworkShared0000.VirtualNetworkName}/subnets/${var.vnetShared000.subnet01.name}"

  workloadProfile = {
    type = "Consumption"
  }

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Container App Environment for ${var.tierTag}",
  }

  depends_on = [module.VirtualNetworkShared0000]
}
