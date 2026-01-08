# Define dasiboards to be imported
# [See](https://github.com/prometheus-community/helm-charts/issues/336#issuecomment-745569146)
resource "kubernetes_config_map" "grafana_dashboards" {
   metadata {
    name      = "grafana-dashboards"
    namespace = var.namespace

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/test"
    }
  }

  data = {
    "aag.json"                          = file("${path.module}/dashboards/Azure/aag.json")
    "azure_managed_cluster.json"        = file("${path.module}/dashboards/Azure/azure_managed_cluster.json")
    "http.json"                         = file("${path.module}/dashboards/http/HTTP.json")
    "kube.json"                         = file("${path.module}/dashboards/kube/kube-state-metrics.json")
    "nodejs.json"                       = file("${path.module}/dashboards/nodejs/nodejs.json")
    "rabbitmq.json"                     = file("${path.module}/dashboards/rabbitmq/rabbitmq.json")
    "readyness.json"                    = file("${path.module}/dashboards/readyness/readyness.json")
    "redis.json"                        = file("${path.module}/dashboards/redis/redis.json")
    "viasuisse.json"                    = file("${path.module}/dashboards/viasuisse/viasuisse.json")
    "cache.json"                        = templatefile("${path.module}/dashboards/cache/cache.json.tftpl", {domains = ["quandopasso","tcs"]})
    "postgresql.json"                   = file("${path.module}/dashboards/postgresql/postgresql.json")
  }
}

resource "random_password" "pass" {
  length           = 16
  special          = true
  override_special = "_%@#"
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name = "grafana-auth"
    namespace = var.namespace
  }
  data = {
    admin-user = "quandopasso_admin"
    admin-password = random_password.pass.result
  }
}
resource "local_sensitive_file" "grafana_credentials" {
    content   =  <<EOT
    user:quandopasso_admin 
    password:${random_password.pass.result}
    EOT
    filename            = ".grafana"
    file_permission     = 0400
}

/**
* Documentation for this helm chart is available [here](https://github.com/prometheus-operator/kube-prometheus)
*/
resource "helm_release" "prometheus-grafana" {
  # OSS: da verificare, ma questo definisce anche la label da inserire nel monitor
  # https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md
  name              = "observability"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  create_namespace  = true
  namespace         = var.namespace
  wait    = true
  timeout = 1200 # seconds (20 min)
  atomic  = true # rollback on failure (recommended)
  # We load grafana and prometheus sub-charts values from this value file
  values               = [ 
    templatefile(
      "${path.module}/values_prom_grafana.template.yml",
      {
        main_url:             var.main_url
        grafana_path:         var.grafana_path
        enable_alert_mail:    var.enable_alert_mail
        smtp_server:          var.smtp_server
        smtp_username:        var.smtp_username
        smtp_password:        var.smtp_password
        prom_retention:       var.prometheus_retention
      }
  )]
  
  depends_on        = [kubernetes_secret.grafana]
}
/**
* PushGateway. 
* This is needed for jobs (e.g. importers)
* prometheus-community https://prometheus-community.github.io/helm-charts
* Service name is pushgateway-prometheus-pushgateway.observability.svc.cluster.local
*/
resource "helm_release" "prometheus-pushgateway" {
  name              = "pushgateway"

  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "prometheus-pushgateway"
  version           = "1.10.1"
  create_namespace  = true
  namespace         = var.namespace
  
  depends_on        = [helm_release.prometheus-grafana]
}

/**
* Service to enable grabs from prometheus
*/
resource "kubernetes_service" "pushgateway" {
  metadata {
    name            = "pushgateway"
    namespace       = var.namespace
    labels          = {
      app =   "prometheus-pushgateway"
    }
  }
  spec {
    selector = {
      app           = "prometheus-pushgateway"
    }
    port {
      port        = 9091
      target_port = 9091
      name        = "pushgatewayport"
    }
    type = "ClusterIP"
  }
  depends_on        = [helm_release.prometheus-pushgateway]
}

resource "helm_release" "pushgateway-servicemonitor" {
  name              = "pushgateway-servicemonitor"

  repository          = var.helm_repository
  repository_username = var.helm_user
  repository_password = var.helm_password

  chart             = "pushgateway"
  version           = "0.0.7"
  create_namespace  = true
  namespace         = var.namespace

  cleanup_on_fail   = true
  
  values               = [ 
    templatefile(
      "${path.module}/values_pushgateway.template.yml", 
      {
        namespace: var.namespace
      }
  )]
  depends_on        = [helm_release.prometheus-grafana]
  timeout           = 600
}