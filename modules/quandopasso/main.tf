locals {
  helm_repository = jsondecode(file("${path.module}/vault/helm_repo.json")).url
}
/**
* Storage resources
*/
/* module "storage" {
  source                  = "./modules/storage"

  environment             = var.environment
  domain                  = var.domain
  location                = var.location
  // resource_group_name     = var.resource_group_name
  // storageSecretName       = var.storageSecretName
  namespace               = var.namespace
} */

module "cache" {
  source                      = "./modules/cache"
  common_namespace            = var.common_namespace
  environment                 = var.environment
  istances                    = var.quandopasso_services.cache.istances
  namespaces                  = var.quandopasso_services.cache.namespaces
  azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
  repository                  = "${var.azcr_prod_host}/cache"
  service_monitor_release     = var.service_monitor_release
  helm_repository             = var.helm_repository
}

module "mobile-api" {
  source                      = "./modules/mobile-api"
  azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
  repository                  = "${var.azcr_prod_host}/mobile-api"
  vt_aspi_importer_repository = "${var.azcr_prod_host}/virtual_tutor"
  helm_repository             = var.helm_repository
  service_monitor_release     = var.service_monitor_release
  istances                    = var.quandopasso_services.mobile-api.istances
  depends_on                  = [ module.cache ]
}

/**
* Utilizzo la URL per psql, quindi db, user, pass non sono significativi
*/
# module "fcd-api" {
#   source                      = "./modules/fcd-api"
#   azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
#   repository                  = "${var.azcr_prod_host}/fcd-api"
#   helm_repository             = var.helm_repository
#   service_monitor_release     = var.service_monitor_release
#   istances                    = var.quandopasso_services.fcd-api.istances
#   db_host                     = var.db_host
#   db_user                     = var.db_user
#   db_pass                     = var.db_password
#   db_name                     = var.fcd_db_name
#   # depends_on                  = [ module.cache ]
# }

module "cb-api" {
  source                      = "./modules/cb-api"
  istances                    = var.quandopasso_services.cb-api.istances
  common_namespace            = var.common_namespace
  azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
  repository                  = "${var.azcr_prod_host}/cb-api"
  helm_repository             = var.helm_repository
  depends_on                  = [ module.cache ]
}

# module "agent-receiver" {
#   source                      = "./modules/agent-receiver"
#   azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
#   repository                  = "${var.azcr_prod_host}/agent-receiver"
#   helm_repository             = var.helm_repository
#   service_monitor_release     = var.service_monitor_release
#   istances                    = var.quandopasso_services.agent-receiver.istances
# }

/**
* SPEED CAMERAS import
**/
module "speedcam_import" {
  source                      = "./modules/speedcam_import"
  azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
  repository                  = "${var.azcr_prod_host}/speedcam"
  istances                    = var.quandopasso_services.speedcam_import.istances
  helm_repository             = var.helm_repository
  depends_on                  = [ module.cache ]
}

/**
* Well Known API. We have only one in the main doamin for all
**/
#module "wellknown-api" {
  #source                      = "./modules/wellknown-api"
  #domain                      = var.domain
  #namespace                   = var.namespace
  #environment                 = var.environment
  #azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
  #repository                  = "${var.azcr_prod_host}/wellknown-api"
  #// Application version in quandopasso container registry
  #tag                         = var.quandopasso_services.wellknown-api.tag
  #replicacount                = var.quandopasso_services.wellknown-api.replicacount
  #// Helm chart version
  #package_version             = var.quandopasso_services.wellknown-api.helm_package_version
  #helm_repository             = local.helm_repository
  #service_monitor_release     = var.service_monitor_release
  #// depends_on                  = [ module.storage ]
#}

# module "atlante" {
#   source                      = "./modules/atlante"
#   namespace                   = var.namespace
#   replicacount                = 1
#   domain                      = var.domain
#   environment                 = var.environment
#   azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
#   repository                  = "${var.azcr_prod_host}/atlante"
#   storageSecretName           = var.storageSecretName
#   // Application version in quandopasso container registry
#   tag                         = var.quandopasso_services.atlante.tag
#   // Helm chart version
#   package_version             = var.quandopasso_services.atlante.helm_package_version
#   helm_repository             = local.helm_repository
#   depends_on                  = [ module.storage ]
# }

module "controlboard" {
  source                      = "./modules/controlboard"
  azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
  repository                  = "${var.azcr_prod_host}/controlboard"
  helm_repository             = var.helm_repository
  istances                    = var.quandopasso_services.controlboard.istances
}

// ----------------------------------------------------------------------------
// Moved to managed service
// ----------------------------------------------------------------------------
// Database for any persistance. In future can be replaced by a managed service
// module "persistance-db" {
//   source                      = "./modules/persistance-db"
//   namespace                   = var.quandopasso_services.persistance-db.namespace
//   backup_namespace            = var.backup_namespace
//   replicacount                = 1
//   environment                 = var.environment
//   helm_repository             = var.helm_repository
//   // Helm chart version
//   package_version             = var.quandopasso_services.persistance-db.helm_package_version
// }

// Tenants persistance managers
/* module "persistance" {
  source                      = "./modules/persistance"
  # --- LE VARIABILI GLOBALI non per istance del DB sono da ELIMINARE ----
  # --- 24.06.2023 ---
  # db_host                     = var.db_host
  # db_user                     = var.db_user
  # db_password                 = var.db_password
  # -----------------------------------------------------------------------
  environment                 = var.environment
  backup_namespace            = var.backup_namespace
  common_namespace            = var.common_namespace
  azcr_pullimage_secret_name  = var.azcr_prod_pullimage_secret_name
  repository                  = "${var.azcr_prod_host}/vsign-persistence"
  helm_repository             = var.helm_repository
  istances                    = var.quandopasso_services.persistance.istances
  # --- 24.06.2023 --- se non ha dato problemi eliminare
  // namespaces                  = var.quandopasso_services.persistance.namespaces
  // depends_on                  = [ module.persistance-db]
} */
