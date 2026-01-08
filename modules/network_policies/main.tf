# resource "kubernetes_network_policy" "test" {
#   metadata {
#     name      = "test"
#     namespace = "quandopasso"
#   }

#   spec {
#     pod_selector {
#       match_expressions {
#         key      = "netPolicy.test"
#         operator = "In"
#         values   = ["true", 1]
#       }
#     }
#     policy_types = ["Egress"]
#   }
# }