terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.67.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "= 2.7.0"
    }
  }

  required_version = "= 1.14.6"

  # backend "azurerm" {
  # }
}
