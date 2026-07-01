###########################
## Provider 4 all
###########################
provider "azurerm" {
  features {
    machine_learning {
      purge_soft_deleted_workspace_on_destroy = true
    }
  }
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {
}