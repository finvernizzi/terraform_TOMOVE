// Backup secrets
resource "kubernetes_secret" "backup" {
  metadata {
    name = var.secretName
    namespace = var.namespace
  }
  data = {
    host           = var.backupHost
    id_rsa         = var.id_rsa
    known_hosts    = var.known_hosts
    mail_key       = var.mail_key
    user           = var.user
  }
}

resource "helm_release" "backup" {
  for_each = {for i, v in var.backups:  i => v}

  name              = "backup-${each.value.database}"
  repository        = var.helm_repository
  chart             = "psql-backup"
  version           = var.package_version

  create_namespace  = true
  namespace         = var.namespace

  cleanup_on_fail   = true
  timeout           = 1200
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace:                  var.namespace
        domain:                     var.domain
        environment:                var.environment
        package_version:            var.package_version
        secretName:                 var.secretName
        backupHost:                 var.backupHost
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        mailTo                      = each.value.mailTo
        schedule                    = each.value.schedule
        database                    = each.value.database
        helm_repository:            var.helm_repository
        tag:                        var.tag
      }
  )]
  depends_on          = [kubernetes_secret.backup]
}