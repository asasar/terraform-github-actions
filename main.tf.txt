########################################
# Resource Group
########################################
module "ResourceGroupSyhunt0000" {
  source = "./Modules/terraform/azurerm/ResourceGroup"

  namingConvention = {
    environmentCode = "k"
    projectCode     = "rdx"
  }
  tierCode         = "sha"
  location         = var.location
  region           = var.region
  increment        = "0000"

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Resources Group for ${var.tierTag}",
  }
}
