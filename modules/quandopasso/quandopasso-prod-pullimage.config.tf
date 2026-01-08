/**
* Creates a Docker Container Registry configuration (auth)
* Sensitive data should be in ${path.module}/vault/acr.json
*/
locals {
  acr_prod_server = jsondecode(file("${path.module}/vault/acr-prod.json")).server
  acr_prod_user = jsondecode(file("${path.module}/vault/acr-prod.json")).user
  acr_prod_password = jsondecode(file("${path.module}/vault/acr-prod.json")).password
}
/**
* Genera un warning sul nome del server perchè è un interpolation only. Da capire come fare per non avere il warning
*/
locals {
  dockerprodconfigjson = {
    "auths": {
      "${local.acr_prod_server}": {
        "auth": base64encode("${local.acr_prod_user}:${local.acr_prod_password}")
      }
    },
    "HttpHeaders": {
      "User-Agent": "Quandopasso automation"
    }
  }
}
/**
* Create a secret for pull image in all required namespaces
**/
resource "kubernetes_secret" "regprodsecret" {
  #for_each = toset( [var.backup_namespace, var.namespace] )
  for_each = toset(var.quandopasso_services.namespaces)
  metadata {
    name = var.azcr_prod_pullimage_secret_name
    namespace = each.key
    labels   = var.labels
  }

  data = {
    ".dockerconfigjson" = jsonencode(local.dockerprodconfigjson)
  }

  type = "kubernetes.io/dockerconfigjson"
}
