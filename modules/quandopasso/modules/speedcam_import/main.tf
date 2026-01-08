locals {
  secrets                 = yamldecode(file("${path.module}/vault/importer.secrets.yml"))
  # secrets                 = jsondecode(file("${path.module}/vault/importer.secrets.json"))
  privatekey              = file("${path.module}/vault/private.key")
}

resource "kubernetes_secret" "speedcam_import" {
  count             = length(var.istances)
  metadata {
    name            = "speedcam-importer"
    namespace       = var.istances[count.index]["namespace"]
  }
  data = {
    cert_file               = local.secrets.importer_cert_file
    jku                     = local.secrets.importer_jku
    kid                     = local.secrets.importer_kid
    sign                    = local.secrets.importer_sign
    sign_alg                = local.secrets.importer_sign_algorithm
    "private.key"           = local.privatekey
  }
}

resource "helm_release" "speedcam" {
  count             = length(var.istances)
  name              = "speedcam-import"

  repository        = var.helm_repository
  chart             = "speedcam-importer"
  version           = var.istances[count.index]["helm_package_version"]
  create_namespace  = true
  namespace         = var.istances[count.index]["namespace"]
  timeout           = 600

  cleanup_on_fail   = true
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace                   : var.istances[count.index]["namespace"]
        domain                      : var.istances[count.index]["domain"]
        tag                         : var.istances[count.index]["tag"]
        environment                 : var.istances[count.index]["environment"]
        vsign_from                  : var.istances[count.index]["vsigns_from"]
        azcr_pullimage_secret_name  : var.azcr_pullimage_secret_name
        repository                  : var.repository
        pullPolicy                  : var.pullPolicy
        vsigns_from                 : var.istances[count.index]["vsigns_from"]
        helm_repository             : var.helm_repository
        avs_radius                  : var.avs_radius
        avs_anticipate              : var.avs_anticipate
        # secrets
        cert_file                   : local.secrets.importer_cert_file
        jku                         : local.secrets.importer_jku
        kid                         : local.secrets.importer_kid
        sign                        : local.secrets.importer_sign
        sign_alg                    : local.secrets.importer_sign_algorithm
      }
  )]
}