##############################
# Resource Group: Networking
##############################
module "ResourceGroupShared0000" {
  source = "../Modules/terraform/azurerm/ResourceGroup"

  namingConvention = { environmentCode = var.namingConvention.environmentCode
                        projectCode     = "sai"
                      }
  tierCode         = "sha"
  location         = var.location
  region           = var.region
  increment        = "0001"

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Networking Resources Group for ${var.tierTag}",
  }
}

##############################
# Virtual Network
##############################
module "VirtualNetworkShared0000" {
  source = "../Modules/terraform/azurerm/VirtualNetwork"

  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0000"
  monitorIncrement  = "0000"
  resourceGroupName = module.ResourceGroupShared0000.ResourceGroupName

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Virtual Network for ${var.tierTag}",
  }

  dnsServers = [var.azureFirewallPrivateIP]
  vnetCIDR   = var.vnetShared000.addressSpace

  subnetsConfig = {
    "${var.vnetShared000.subnet00.name}" = {
      addressPrefixes                = var.vnetShared000.subnet00.addressSpace
      delegations                    = []
    }
    "${var.vnetShared000.subnet01.name}" = {
      addressPrefixes = var.vnetShared000.subnet01.addressSpace
      delegations = [
        {
          name        = "Microsoft.App.environments"
          serviceName = "Microsoft.App/environments"
          actions     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      ]
    }
  }
}
