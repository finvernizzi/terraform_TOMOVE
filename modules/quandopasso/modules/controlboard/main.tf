/*resource "kubernetes_secret" "controlboard" {
  metadata {
    name            = "secrets-controlboard"
    namespace       = var.domain
  }

  data = {
    queue_user      = jsondecode(file("${path.module}/vault/cache.secrets.json")).queue_user
    queue_password  = jsondecode(file("${path.module}/vault/cache.secrets.json")).queue_password
  }
}*/

resource "helm_release" "controlboard" {
  count             = length(var.istances)
  name              = "controlboard-${var.istances[count.index]["domain"]}"

  repository        = var.helm_repository
  chart             = "controlboard"
  version           = var.istances[count.index]["helm_package_version"]
  timeout           = 10000
  create_namespace  = true
  namespace         = var.istances[count.index]["namespace"]

  cleanup_on_fail   = true
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace: var.istances[count.index]["namespace"]
        replicacount: var.istances[count.index]["replicacount"]
        domain: var.istances[count.index]["domain"]
        environment: var.istances[count.index]["environment"]
        backend_path: var.istances[count.index]["backend_path"]
        well_known_url: var.istances[count.index]["well_known_url"]
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        repository: var.repository
        tag: var.istances[count.index]["tag"]
        pullPolicy: var.pullPolicy
        base_href: "/${var.istances[count.index]["domain"]}/controlboard/"
      }
  )]
}