locals {
  queue_user      = jsondecode(file("${path.module}/vault/agent-receiver.secrets.json")).queue_user
  queue_password  = jsondecode(file("${path.module}/vault/agent-receiver.secrets.json")).queue_password
  api_key         = jsondecode(file("${path.module}/vault/agent-receiver.secrets.json")).api_key
}

# resource "kubernetes_secret" "agent-receiver" {
#   count             = length(var.namespaces)
#   metadata {
#     name            = "agent-receiver"
#     namespace       = var.namespaces[count.index]
#   }

#   data = {
#     queue_user      = jsondecode(file("${path.module}/vault/agent.receiver.secrets.json")).queue_user
#     queue_password  = jsondecode(file("${path.module}/vault/agent.receiver.secrets.json")).queue_password
#   }
# }

resource "helm_release" "agent-receiver" {
  count             = length(var.istances)
  name              = "agent-receiver-${var.istances[count.index]["domain"]}"

  repository        = var.helm_repository
  chart             = "agent-receiver"
  version           = var.istances[count.index]["helm_package_version"]
  create_namespace  = true
  namespace         = var.istances[count.index]["namespace"]

  cleanup_on_fail   = true
  timeout           = 1200
  
  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        domain: var.istances[count.index]["domain"]
        namespace: var.istances[count.index]["namespace"]
        replicacount: var.istances[count.index]["replicacount"]
        domain: var.istances[count.index]["domain"]
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        repository: var.repository
        tag: var.istances[count.index]["tag"]
        pullPolicy: var.pullPolicy
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        queue_user: local.queue_user
        queue_password: local.queue_password
        queue_vhost: var.istances[count.index]["queue_vhost"]
        queue_exchange: var.istances[count.index]["queue_exchange"]
        api_key: local.api_key
        customer_name:var.istances[count.index]["customer_name"]
      }
  )]
}