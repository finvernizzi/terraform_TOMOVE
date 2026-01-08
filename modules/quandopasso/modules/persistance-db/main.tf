/**
* Database secrets
*/
// resource "kubernetes_secret" "vsign-persistence" {
//   metadata {
//     name            = "vsigns-persistance"
//     namespace       = var.namespace
//   }

//   data = {
//     db_user      = jsondecode(file("${path.module}/vault/persistance.secrets.json")).db_user
//     db_password  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).db_password
//     queue_user  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).queue_user
//     exporter_data_source_name = jsondecode(file("${path.module}/vault/persistance.secrets.json")).exporter_data_source
//     # db_database = var.database
//     # queue_password  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).queue_password
//   }
// }

// resource "kubernetes_secret" "vsign-persistence-backup" {
//   metadata {
//     name            = "secrets-vsigns-persistance"
//     namespace       = var.backup_namespace
//   }

//   data = {
//     db_user      = jsondecode(file("${path.module}/vault/persistance.secrets.json")).db_user
//     db_password  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).db_password
//     queue_user  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).queue_user
//     # queue_password  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).queue_password
//   }
// }

/**
* Persistance Database. Common to all instances
*/
// resource "helm_release" "vsign-persistance-db" {
//   name              = "vsign-persistance-db"

//   repository        = var.helm_repository
//   chart             = "vsign-persistence-db"
//   version           = var.package_version
//   create_namespace  = true
//   namespace         = var.namespace
//   timeout           = 1200
//   wait_for_jobs     = true

//   cleanup_on_fail   = true
  
//   values               = [ 
//     templatefile(
//       "${path.module}/values.template.yml", 
//       {
//         namespace:                  var.namespace
//         replicacount:               var.replicacount
//         environment:                var.environment
//         storagesize:                var.storagesize
//         storageclass:               var.storageclass
//       }
//   )]
// }