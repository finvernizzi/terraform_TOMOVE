resource "helm_release" "wellknown-api" {
  name              = "wellknown-api"

  repository        = var.helm_repository
  chart             = "wellknown-api"
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
        rate_limit: var.rate_limit
        service_monitor_release: var.service_monitor_release
      }
  )]
}