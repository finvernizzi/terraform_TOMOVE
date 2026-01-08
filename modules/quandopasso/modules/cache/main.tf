resource "kubernetes_secret" "cache" {
  count             = length(var.namespaces)
  metadata {
    name            = "secrets-cache"
    namespace       = var.namespaces[count.index]
  }

  data = {
    queue_user      = jsondecode(file("${path.module}/vault/cache.secrets.json")).queue_user
    queue_password  = jsondecode(file("${path.module}/vault/cache.secrets.json")).queue_password
  }
}

resource "helm_release" "cache" {
  count             = length(var.istances)

  name              = "cache-${var.istances[count.index]["domain"]}"
  namespace         = var.istances[count.index]["namespace"]

  repository        = var.helm_repository
  chart             = "cache"
  version           = var.istances[count.index]["helm_package_version"]
  create_namespace  = true

  cleanup_on_fail   = true
  timeout           = 1200

  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace:                  var.istances[count.index]["namespace"]
        replicacount:               var.istances[count.index]["replicacount"]
        domain:                     var.istances[count.index]["domain"]
        exchange:                   var.istances[count.index]["exchange"]
        queue_vhost:                var.istances[count.index]["queue_vhost"]
        environment:                var.environment
        common_namespace:           var.common_namespace
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        repository:                 var.repository
        tag:                        var.istances[count.index]["tag"]
        pullPolicy:                 var.pullPolicy
        service_monitor_release:    var.service_monitor_release
        mixer_config:               file(format("%s/%s",path.root, var.istances[count.index]["mixer_config"]))
      }
  )]
  depends_on          = [kubernetes_secret.cache]
}
