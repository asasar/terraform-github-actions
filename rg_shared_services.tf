########################################
# Resource Group
########################################
module "ResourceGroupSyhunt0000" {
  source = "./Modules/terraform/azurerm/ResourceGroup"

  namingConvention = var.namingConvention
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

########################################
# Container App Environment
########################################
module "ContainerAppEnvironmentShared0000" {
  source = "./Modules/terraform/azurerm/ContainerAppsEnvironment"

  namingConvention                      = var.namingConvention
  tierCode                              = "sha"
  location                              = var.location
  region                                = var.region
  increment                             = "0001"
  incrementResourceGroupContainerAppEnv = "0002"
  resourceGroupName                     = module.ResourceGroupSyhunt0000.ResourceGroupName
  logAnalyticsWorkspaceID               = var.logAnalyticsWorkspaceID
  zoneRedundancyEnabled                 = false

  infrastructureSubnetID = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.ResourceGroupShared0000.ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${module.VirtualNetworkShared0000.VirtualNetworkName}/subnets/${var.vnetShared000.subnet01.name}"

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

########################################
# Managed Identity
########################################
module "ManagedIdentitySyhunt0000" {
  source = "./Modules/terraform/azurerm/ManagedIdentity"

  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0000"
  resourceGroupName = module.ResourceGroupSyhunt0000.ResourceGroupName

  tags = var.tags
  specificTags = {
    Tier                       = var.tierTag,
    ManagedIdentityDescription = "Managed Identity for ${var.tierTag}",
  }
}

########################################
# Application Insights 
########################################
module "ApplicationInsightsSyhunt0000" {
  source = "./Modules/terraform/azurerm/ApplicationInsights"

  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0000"
  resourceGroupName = module.ResourceGroupSyhunt0000.ResourceGroupName

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Application Insights for ${var.tierTag}",
  }

  workspaceID     = var.logAnalyticsWorkspaceID
  applicationType = "web"
  retentionInDays = 90
}

########################################
# Key Vault 
########################################
module "KeyVaultSyhunt0000" {
  source = "./Modules/terraform/azurerm/KeyVault/Vault"

  namingConvention             = var.namingConvention
  tierCode                     = "sha"
  location                     = var.location
  region                       = var.region
  increment                    = "0000"
  monitorIncrement             = "0001"
  resourceGroupName            = module.ResourceGroupSyhunt0000.ResourceGroupName
  purgeProtectionEnable        = true
  publicAccessEnable           = true
  enabledForTemplateDeployment = true
  tags                         = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Key Vault for ${var.tierTag}",
  }

  logAnalyticsWorkspaceConfig = {
    logAnalyticsID      = var.logAnalyticsWorkspaceID
    logAnalyticsType    = "Dedicated"
    logAnalyticsLogs    = ["AuditEvent"]
    logAnalyticsMetrics = ["AllMetrics"]
  }
}

module "PrivateEndpointKeyVaultSyhunt0000" {
  source = "./Modules/terraform/azurerm/PrivateEndpoint"

  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0000"
  resourceGroupName = module.ResourceGroupSyhunt0000.ResourceGroupName

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Key Vault Private Endpoint for ${var.tierTag}",
  }
  subresourceName = ["vault"]

  subnetID       = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.ResourceGroupShared0000.ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${module.VirtualNetworkShared0000.VirtualNetworkName}/subnets/${var.vnetShared000.subnet00.name}"
  linkResourceID = module.KeyVaultSyhunt0000.KeyVaultID

  depends_on = [module.VirtualNetworkShared0000, module.KeyVaultSyhunt0000]
}

########################################
# Storage Account 
########################################
module "StorageAccountSyhunt0000" {
  source = "./Modules/terraform/azurerm/StorageAccount"

  namingConvention                = var.namingConvention
  tierCode                        = "sha"
  location                        = var.location
  region                          = var.region
  increment                       = "0000"
  monitorIncrement                = "0002"
  resourceGroupName               = module.ResourceGroupSyhunt0000.ResourceGroupName
  publicAccess                    = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Storage account for ${var.tierTag}",
  }

  storageAccountConfig = {
    accountKind           = "StorageV2"
    accountTier           = "Standard"
    replicationType       = "LRS"
    accessTier            = "Hot"
    sftp                  = false
    enableHttpsTraficOnly = true
    enableLargeFileSize   = false
    blobAnonymousAccess   = false
  }

  logAnalyticsWorkspaceConfig = {
    logAnalyticsID = var.logAnalyticsWorkspaceID
    logAnalyticsMetrics = [
      "Transaction",
      "Capacity"
    ]
  }
}

module "PrivateEndpointStorageAccountBlob0000" {
  source            = "./Modules/terraform/azurerm/PrivateEndpoint"
  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0001"
  resourceGroupName = module.ResourceGroupSyhunt0000.ResourceGroupName

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Blob Storage Private Endpoint for ${var.tierTag}",
  }
  subresourceName = ["blob"]

  subnetID       = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.ResourceGroupShared0000.ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${module.VirtualNetworkShared0000.VirtualNetworkName}/subnets/${var.vnetShared000.subnet00.name}"
  linkResourceID = module.StorageAccountSyhunt0000.StorageAccountID

  depends_on = [module.VirtualNetworkShared0000, module.StorageAccountSyhunt0000]
}

########################################
# PostgreSQL Flexible Server
########################################
module "PostgreSqlFlexibleSyhunt0000" {
  source            = "./Modules/terraform/azurerm/PostgreSqlFlexible"
  namingConvention  = var.namingConvention
  tierCode          = "sha"
  increment         = "0000"
  monitorIncrement  = "0000"
  location          = var.location
  resourceGroupName = module.ResourceGroupSyhunt0000.ResourceGroupName
  postgreVersion    = "16"
  sku               = "GP_Standard_D2ds_v5"
  postgreAuthentication = {
    entraIDAuth     = true
    passwordAuth    = true
    postgreLogin    = var.postgresqlAdminLogin
    postgrePassword = var.postgresqlAdminPassword
  }
  storageConfig = {
    storageTiers = "P10"
    storageSize  = 131072
  }
  logAnalyticsWorkspaceID = var.logAnalyticsWorkspaceID
  specificTags = {
    Tier        = var.tierTag,
    Description = "PostgreSql Flexible server for ${var.tierTag}"
  }
  tags = var.tags
}

module "PrivateEndpointPostgreSqlSyhunt0000" {
  source = "./Modules/terraform/azurerm/PrivateEndpoint"

  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0002"
  resourceGroupName = module.ResourceGroupSyhunt0000.ResourceGroupName

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "PostgreSql Flexible Private Endpoint for ${var.tierTag}",
  }
  subresourceName = ["postgresqlServer"]

  subnetID       = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.ResourceGroupShared0000.ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${module.VirtualNetworkShared0000.VirtualNetworkName}/subnets/${var.vnetShared000.subnet00.name}"
  linkResourceID = module.PostgreSqlFlexibleSyhunt0000.PostgreSqlID

  depends_on = [module.VirtualNetworkShared0000, module.PostgreSqlFlexibleSyhunt0000]
}


########################################
# AI Foundry (Shared GenAI Services)
########################################
module "AIServicesSharedSyhunt0000" {
  source = "./Modules/terraform/azapi/AIHubCognitiveServiceType"

  namingConvention        = var.namingConvention
  tierCode                = "sha"
  location                = var.locationOpenAI
  region                  = var.regionOpenAI
  increment               = "0000"
  monitorIncrement        = "000"
  resourceGroupID         = module.ResourceGroupSyhunt0000.ResourceGroupID
  sku_name                = "S0"
  publicNetworkAccess     = "Disabled"
  logAnalyticsWorkspaceID = var.logAnalyticsWorkspaceID
  models                  = var.modelsShared

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "AI Foundry for ${var.tierTag}",
  }
}

module "PrivateEndpointAIServicesSharedSyhunt0000" {
  source = "./Modules/terraform/azurerm/PrivateEndpoint"

  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0003"
  resourceGroupName = module.ResourceGroupSyhunt0000.ResourceGroupName
  tags              = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Private Endpoint Foundry for ${var.tierTag}",
  }

  subresourceName = ["account"]
  subnetID        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.ResourceGroupShared0000.ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${module.VirtualNetworkShared0000.VirtualNetworkName}/subnets/${var.vnetShared000.subnet00.name}"
  linkResourceID  = module.AIServicesSharedSyhunt0000.AIHubInstanceID
  depends_on      = [module.VirtualNetworkShared0000, module.AIServicesSharedSyhunt0000]
}


resource "azurerm_key_vault_secret" "KeyVaultSecretSyhunt0000_postgresdb_username" {
  name         = "postgresdb-username"
  value        = var.postgresqlAdminLogin
  key_vault_id = module.KeyVaultSyhunt0000.KeyVaultID

  depends_on = [azurerm_role_assignment.terraform_caller_keyvault_secrets_officer, module.PrivateEndpointKeyVaultSyhunt0000, module.PostgreSqlFlexibleSyhunt0000]
}

resource "azurerm_key_vault_secret" "KeyVaultSecretSyhunt0000_postgresdb_password" {
  name         = "postgresdb-password"
  value        = var.postgresqlAdminPassword
  key_vault_id = module.KeyVaultSyhunt0000.KeyVaultID

  depends_on = [azurerm_role_assignment.terraform_caller_keyvault_secrets_officer, module.PrivateEndpointKeyVaultSyhunt0000, module.PrivateEndpointPostgreSqlSyhunt0000]
}

resource "azurerm_key_vault_secret" "KeyVaultSecretSyhunt0000_postgresdb_connection_string" {
  name  = "postgresdb-connection-string"
  value = "Host=PostgreSqlServer;Port=5432;Database=postgres;Username=${var.postgresqlAdminLogin};Password=${var.postgresqlAdminPassword};Ssl Mode=Require;"

  key_vault_id = module.KeyVaultSyhunt0000.KeyVaultID

  depends_on = [azurerm_role_assignment.terraform_caller_keyvault_secrets_officer, module.PrivateEndpointKeyVaultSyhunt0000, module.PrivateEndpointPostgreSqlSyhunt0000]
}
