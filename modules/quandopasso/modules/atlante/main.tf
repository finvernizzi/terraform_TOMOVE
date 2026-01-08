resource "helm_release" "atlante" {
  name              = "atlante"

  repository        = var.helm_repository
  chart             = "atlante"
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
        debug: var.debug
        pullPolicy: var.pullPolicy
        storageCapacity: var.storageCapacity
        storagesecret: var.storageSecretName
      }
  )]
}