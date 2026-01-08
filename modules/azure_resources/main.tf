# TODO: cambiare nome interno alla resource group
# resource "azurerm_resource_group" "k8s" {
#     name     = var.resource_group_name
#     location = var.location
#     tags     = var.tags
# }

/*
* Give the application Owner role over the newly created resource group (and linked MC resource group)
*/
# resource "azurerm_role_assignment" "service_principal_OWNER" {
#   scope                = azurerm_resource_group.k8s.id
#   role_definition_name = "Owner"
#   principal_id         = var.aks_service_principal_object_id 
# }

/**
* Key Vault
**/
# resource "azurerm_key_vault" "key_vault" {
#   name                            = "qp-secrets"
#   location                        = var.location
#   resource_group_name             = var.resource_group_name
#   enabled_for_disk_encryption     = true
#   tenant_id                       = var.aks_service_principal_id
#   soft_delete_retention_days      = 7
#   purge_protection_enabled        = false
#   public_network_access_enabled   = false

#   sku_name = "standard"

#   access_policy {
#     tenant_id = var.aks_service_principal_id
#     object_id = var.aks_service_principal_object_id

#     key_permissions = [
#       "Get",
#     ]

#     secret_permissions = [
#       "Get",
#     ]

#     storage_permissions = [
#       "Get",
#     ]
#   }
# }
