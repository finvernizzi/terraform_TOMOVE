# Qui occorre specializzare per tenant in modo che vada a finire in database distinti e non tutto in postgre
# ---- Da eliminare e utilizzare i secret specializzati ----
# ---- Se confermato si può rimuovere (24-06-2023) ---
# resource "kubernetes_secret" "vsign-persistence" {
#   for_each = toset(var.namespaces)
#   metadata {
#     name            = "vsigns-persistance"
#     namespace       = each.value
#   }
#   data = {
#     db_user      = var.db_user
#     db_password  = var.db_password
#     queue_user  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).queue_user
#     db_url      = "postgres://${var.db_user}:${var.db_password}@${var.db_host}/postgres?sslmode=${var.db_ssl_mode}"
#   }
# }
# For each domain, use distinct configurations. The secret name is the same, but the domain changes
# resource "kubernetes_secret" "vsign-persistence-domain" {
#   count             = length(var.istances)
#   metadata {
#     name            = "vsigns-persistance"
#     namespace       = var.istances[count.index]["namespace"]
#   }
#   data = {
#     db_user      = var.istances[count.index]["db_user"]
#     db_password  = var.istances[count.index]["db_pass"]
#     queue_user  = jsondecode(file("${path.module}/vault/persistance.secrets.json")).queue_user
#     db_url      = "postgres://${var.istances[count.index]["db_user"]}:${var.istances[count.index]["db_pass"]}@${var.istances[count.index]["db_host"]}/${var.istances[count.index]["db_name"]}?sslmode=${var.istances[count.index]["db_ssl_mode"]}"
#   }
# }

resource "helm_release" "vsign-persistance" {
  count             = length(var.istances)
  name              = "vsign-persistance-${var.istances[count.index]["domain"]}"
  namespace         = var.istances[count.index]["namespace"]

  repository        = var.helm_repository
  chart             = "vsign-persistence"
  version           = var.istances[count.index]["helm_package_version"]
  timeout           = 3600 # 1 hour
  wait_for_jobs     = true

  cleanup_on_fail   = true
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace:                  var.istances[count.index]["namespace"]
        db_host:                    var.istances[count.index]["db_host"]
        db_synch:                   var.istances[count.index]["db_synch"]
        db_options:                 var.istances[count.index]["db_options"]
        dbNamespace:                var.istances[count.index]["dbNamespace"]
        replicacount:               var.istances[count.index]["replicacount"]
        domain:                     var.istances[count.index]["domain"]
        environment:                var.environment
        common_namespace:           var.common_namespace
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        repository:                 var.repository
        tag:                        var.istances[count.index]["tag"]
        pullPolicy:                 var.pullPolicy
        database:                   var.istances[count.index]["db_name"]
        track:                      var.istances[count.index]["track"]
        excludeatcc:                var.istances[count.index]["excludeatcc"]
        debug:                      var.istances[count.index]["debug"]
        exchange:                   var.istances[count.index]["exchange"]
        vhost:                      var.istances[count.index]["queue_vhost"]
      }
  )]
}