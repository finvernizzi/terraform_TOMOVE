/**
* Secrets for controlboard api service
*/
resource "kubernetes_secret" "cb-api" {
  count             = length(var.istances)
  metadata {
    name            = "cb-api-${var.istances[count.index]["domain"]}"
    namespace       = var.istances[count.index]["namespace"]
  }

  data = {
    "sign"                = jsondecode(file("${path.module}/vault/cb-api.secrets.json")).sign,
    "sign_algorithm"      = jsondecode(file("${path.module}/vault/cb-api.secrets.json")).sign_algorithm,
    "jku"                 = jsondecode(file("${path.module}/vault/cb-api.secrets.json")).jku,
    "kid"                 = jsondecode(file("${path.module}/vault/cb-api.secrets.json")).kid,
    "queue_user"          = jsondecode(file("${path.module}/vault/cb-api.secrets.json")).queue_user,
    "queue_password"      = jsondecode(file("${path.module}/vault/cb-api.secrets.json")).queue_password,
    "cert_file"           = jsondecode(file("${path.module}/vault/cb-api.secrets.json")).cert_file,
    "cert.key"            = base64decode(jsondecode(file("${path.module}/vault/cb-api.secrets.json")).cert_key)
  }
}

resource "helm_release" "cb-api" {
  count             = length(var.istances)
  name              = "cb-api-${var.istances[count.index]["domain"]}"

  repository        = var.helm_repository
  chart             = "cb-api"
  version           = var.istances[count.index]["helm_package_version"]
  create_namespace  = true
  namespace         = var.istances[count.index]["namespace"]
  timeout           = 600

  cleanup_on_fail   = true
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace: var.istances[count.index]["namespace"]
        replicacount: var.istances[count.index]["replicacount"]
        common_namespace: var.common_namespace
        domain: var.istances[count.index]["domain"]
        environment: var.istances[count.index]["environment"]
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        repository: var.repository
        tag: var.istances[count.index]["tag"]
        vhost: var.istances[count.index]["vhost"]
        exchange: var.istances[count.index]["exchange"]
        pullPolicy: var.pullPolicy
        api_version: var.istances[count.index]["api_version"]
        debug: var.istances[count.index]["debug"]
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        service_monitor_release: var.service_monitor_release
        jws_iss: var.istances[count.index]["jws_iss"]
        jws_sec: var.istances[count.index]["jws_sec"]
      }
  )]
}