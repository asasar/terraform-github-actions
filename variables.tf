variable "location" {
  type        = string
  description = "Deployment location"
}

variable "region" {
  type        = string
  description = "Deployment region short code"
}

variable "locationOpenAI" {
  type        = string
  description = "Deployment location for OpenAI"
}

variable "regionOpenAI" {
  type        = string
  description = "Deployment region short code for Foundry"
}

variable "tierTag" {
  type        = string
  description = "Deployment tier tag"
  default     = "Syhunt"
}

variable "namingConvention" {
  type        = map(string)
  description = "Value for naming convention"
}

variable "tags" {
  type        = map(string)
  description = "Default tag list"
}

variable "vnetShared000" {
  type = object({
    addressSpace = list(string)
    subnet00 = object({
      name         = string
      addressSpace = list(string)
    })
    subnet01 = object({
      name         = string
      addressSpace = list(string)
    })
  })
  description = "Virtual Network and Subnets configuration for DSEP Networking"
}

variable "azureFirewallPrivateIP" {
  type        = string
  description = "Azure Firewall private IP"
}

variable "applicationSpecificNsgRules" {
  type = map(list(object({
    name                     = string
    priority                 = number
    direction                = string
    access                   = string
    protocol                 = string
    sourcePortRange          = string
    destinationPortRange     = string
    sourceAddressPrefix      = string
    destinationAddressPrefix = string
    description              = string
  })))
  description = "Application-specific NSG rules keyed by subnet key (pep, cae, pep_dev, cae_dev). Must be provided by the application team before deployment."
  default = {
    pep = []
    cae = []
  }
}

variable "logAnalyticsWorkspaceID" {
  type        = string
  description = "ID of the external Log Analytics Workspace for diagnostic logs (azrfrclawpmgtlog0000)"
}

variable "modelsShared" {
  type = map(object({
    deploymentName = string
    modelName      = string
    format         = string
    version        = string
    type           = string
    capacity       = string
  }))
  description = "Catalog of model deployments for the Shared GenAI AI Services account. Each entry is deployed once on the shared hub and shared by every project; costs are broken down per model directly."
  default     = {}
}

variable "postgresqlAdminLogin" {
  type        = string
  description = "PostgreSQL admin login username"
  sensitive   = true
}

variable "postgresqlAdminPassword" {
  type        = string
  description = "PostgreSQL admin login password"
  sensitive   = true
}
