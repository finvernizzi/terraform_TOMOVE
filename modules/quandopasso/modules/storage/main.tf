/**
To have higher probability the Storage account name is unique
*/
resource "random_string" "random" {
  length           = 4
  special          = false
  upper            = false
}

/**
* Storage account to contain all filestorage shares
* Create HERE all needed file shares
* - Atlante maps
* - Public certificates
*/
resource "azurerm_storage_account" "storageaccount" {
  name                     = "${var.environment}${random_string.random.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = "StorageV2" 
  account_replication_type = "LRS"
  account_tier             = "Standard"
  tags = {
        environment = var.environment
        domain = var.domain
    }
}
/**
* File shares
**/
resource "azurerm_storage_share" "geoJsonFileShare" {
  name                      = "geojson"
  storage_account_name      = azurerm_storage_account.storageaccount.name
  quota                     = var.fileSharesQuota
}
resource "azurerm_storage_share" "publicCertificates" {
  name                      = "public-certificates"
  storage_account_name      = azurerm_storage_account.storageaccount.name
  quota                     = var.fileSharesQuota
}
/**
* Populates geoJsonFileShare
**/
resource "azurerm_storage_share_file" "paths" {
  for_each = fileset("${path.root}/files/paths/", "*")
  name             = each.key
  storage_share_id = azurerm_storage_share.geoJsonFileShare.id
  source           = "${path.root}/files/paths/${each.key}"
}
/**
* Populates public-certificates
**/
resource "azurerm_storage_share_file" "certificates" {
  for_each = fileset("${path.root}/files/certificates/", "*")
  name             = each.key
  storage_share_id = azurerm_storage_share.publicCertificates.id
  source           = "${path.root}/files/certificates/${each.key}"
}

/**
* Create a K8s secret to access Azure storages
**/ 
resource "kubernetes_secret" "sasecret" {
  metadata {
    name                    = var.storageSecretName
    namespace               = var.namespace
  }
  data = {
    azurestorageaccountkey  = azurerm_storage_account.storageaccount.primary_access_key
    azurestorageaccountname = azurerm_storage_account.storageaccount.name
  }
}
/**
* Create a K8s secret to access Azure storages - default namespace
**/ 
resource "kubernetes_secret" "sasecret-default" {
  metadata {
    name                    = var.storageSecretName
    # namespace               = var.namespace
  }
  data = {
    azurestorageaccountkey  = azurerm_storage_account.storageaccount.primary_access_key
    azurestorageaccountname = azurerm_storage_account.storageaccount.name
  }
}
/**
* Persistent Volumes created on File Share created by azure resources module
* geojson
*/
resource "kubernetes_persistent_volume" "geojson" {
  metadata {
    name                    = "geojson-pv"
    labels                  = {"usage":"geojson-pv"}
  }
  spec {
    capacity = {
      storage               = "1Gi"
    }
    access_modes = ["ReadOnlyMany"]
    persistent_volume_source {
      azure_file {
        // read_only           = true
        secret_name         = var.storageSecretName
        share_name          = "geojson"
        secret_namespace     = var.namespace
      }
    }
  }
}
/**
* certificates and well-known (public) data
*/
resource "kubernetes_persistent_volume" "certificates-pv" {
  metadata {
    name                    = "certificates-pv"
    labels                  = {"usage":"certificates-pv"}
  }
  spec {
    capacity = {
      storage               = "1Gi"
    }
    access_modes = ["ReadOnlyMany"]
    persistent_volume_source {
      azure_file {
        // read_only           = true
        secret_name         = var.storageSecretName
        share_name          = "public-certificates"
        secret_namespace     = var.namespace
      }
    }
  }
}
