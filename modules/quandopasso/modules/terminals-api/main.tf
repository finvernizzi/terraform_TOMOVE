/**
* Secrets for terminals api service
*/
resource "kubernetes_secret" "terminals-api" {
  metadata {
    name            = "secrets-terminals-api"
    namespace       = var.namespace
  }

  data = {
    "token"                = jsondecode(file("${path.module}/vault/terminals-api.secrets.json")).token,
    "influx_token"         = jsondecode(file("${path.module}/vault/terminals-api.secrets.json")).influx_token
  }
}

resource "helm_release" "terminals-api" {
  name              = "terminals-api"

  repository        = var.helm_repository
  chart             = "terminals-api"
  version           = var.package_version
  create_namespace  = true
  namespace         = var.namespace

  cleanup_on_fail   = true
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace: var.namespace
        replicacount: var.replicacount
        domain: var.domain
        environment: var.environment
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        repository: var.repository
        tag: var.tag
        pullPolicy: var.pullPolicy
        api_version: var.api_version
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        service_monitor_release: var.service_monitor_release
        typeorm_host: var.typeorm_host
        typeorm_database: var.typeorm_database
      }
  )]
   depends_on                  = [ kubernetes_secret.terminals-api ]
}