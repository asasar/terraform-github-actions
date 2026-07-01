########################################
# RBAC — Key Role Assignments
########################################


# Current Terraform caller -> Key Vault: Key Vault Secrets Officer
resource "azurerm_role_assignment" "terraform_caller_keyvault_secrets_officer" {
  scope                = module.KeyVaultSyhunt0000.KeyVaultID
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  description          = "Allows Terraform caller to create and manage Key Vault secrets"

  depends_on = [module.KeyVaultSyhunt0000]
}


# # Container Apps MI → Container Registry: AcrPull
# resource "azurerm_role_assignment" "container_apps_mi_acr_pull" {
#   scope                = module.ContainerRegistryShared0000.AcrID
#   role_definition_name = "AcrPull"
#   principal_id         = module.ManagedIdentitySyhunt0000.ManagedIdentityPrincipalID
#   description          = "Allows Container Apps MI to pull images from Container Registry"
# }


# MI → Key Vault : Key Vault Secrets User
resource "azurerm_role_assignment" "ml_workspace_exp_keyvault_secrets_user" {
  scope                = module.KeyVaultSyhunt0000.KeyVaultID
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.ManagedIdentitySyhunt0000.ManagedIdentityPrincipalID
  description          = "Allows MI to read Key Vault secrets"

  depends_on = [module.ManagedIdentitySyhunt0000, module.KeyVaultSyhunt0000]
}


# MI → Storage : Storage Blob Data Contributor
resource "azurerm_role_assignment" "ml_cluster_exp_storage_blob_contributor" {
  scope                = module.StorageAccountSyhunt0000.StorageAccountID
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.ManagedIdentitySyhunt0000.ManagedIdentityPrincipalID
  description          = "Allows MI to contribute to blob storage"

  depends_on = [module.ManagedIdentitySyhunt0000, module.StorageAccountSyhunt0000]
}


# MI → Azure Foundry : Azure AI Developer
resource "azurerm_role_assignment" "ml_cluster_exp_azure_ai_developer" {
  scope                = module.AIServicesSharedSyhunt0000.AIHubInstanceID
  role_definition_name = "Azure AI Developer"
  principal_id         = module.ManagedIdentitySyhunt0000.ManagedIdentityPrincipalID
  description          = "Allows MI to access Azure AI Developer resources"

  depends_on = [module.ManagedIdentitySyhunt0000, module.AIServicesSharedSyhunt0000]
}
