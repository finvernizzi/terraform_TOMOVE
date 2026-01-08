/**
* Secrets for Pullimage from quandopasso container registry
* We assume we have max an instance for each domain on each namespace
*/
resource "kubernetes_secret" "fcd-api" {
  count             = length(var.istances)
  metadata {
    name            = "fcd-api-${var.istances[count.index]["domain"]}"
    namespace       = var.istances[count.index]["namespace"]
  }
}

resource "helm_release" "fcd-api" {
  count             = length(var.istances)
  name              = "fcd-api-${var.istances[count.index]["domain"]}"

  repository        = var.helm_repository
  chart             = "fcd-api"
  version           = var.istances[count.index]["helm_package_version"]
  create_namespace  = true
  namespace         = var.istances[count.index]["namespace"]

  cleanup_on_fail   = true
  timeout           = 1200
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace: var.istances[count.index]["namespace"]
        replicacount: var.istances[count.index]["replicacount"]
        domain: var.istances[count.index]["domain"]
        environment: var.istances[count.index]["environment"]
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        repository: var.repository
        tag: var.istances[count.index]["tag"]
        pullPolicy: var.pullPolicy
        db_url:var.istances[count.index]["db_url"]
        db_host:var.db_host
        db_user:var.db_user
        db_pass:var.db_pass
        db_name:var.db_name
        node_environment: var.node_environment
        api_version: var.istances[count.index]["api_version"]
        swagger_mode: "false"
        node_environment: "production"
        token_list: var.istances[count.index]["token_list"]
      }
  )]
}