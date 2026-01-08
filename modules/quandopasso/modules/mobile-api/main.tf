/**
* Secrets for Pullimage from quandopasso container registry
* We assume we have max an instance for each domain on each namespace
*/
resource "kubernetes_secret" "mobile-api" {
  count             = length(var.istances)
  metadata {
    name            = "mobile-api-${var.istances[count.index]["domain"]}"
    namespace       = var.istances[count.index]["namespace"]
  }

  data = {
    jws_iss       = jsondecode(file("${path.module}/vault/mobile-api.secrets.json")).jws_iss
    jws_sec       = jsondecode(file("${path.module}/vault/mobile-api.secrets.json")).jws_sec
    token         = jsondecode(file("${path.module}/vault/mobile-api.secrets.json")).token
    vt_table_token= random_string.vt_token.result
    "cert_file"   = jsondecode(file("${path.module}/vault/mobile-api.secrets.json")).cert_file,
    "cert_key"    = base64decode(jsondecode(file("${path.module}/vault/mobile-api.secrets.json")).cert_key)
    "kid"                 = jsondecode(file("${path.module}/vault/mobile-api.secrets.json")).kid
  }
}

resource "random_string" "vt_token" {
  length  = 10
  upper = true
  lower = true
  special = false
}

resource "helm_release" "mobile-api" {
  count             = length(var.istances)
  name              = "mobile-api-${var.istances[count.index]["domain"]}"

  repository        = var.helm_repository
  chart             = "mobile-api"
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
        api_version: var.istances[count.index]["api_version"]
        azcr_pullimage_secret_name: var.azcr_pullimage_secret_name
        service_monitor_release: var.service_monitor_release
        rate_limit: var.rate_limit
        debug: var.istances[count.index]["debug"]
        categories: file("${path.module}/vault/categories.json")
        vt_aspi_importer_enabled: var.istances[count.index]["vt_aspi_importer_enabled"]
        mobile_api_port: var.istances[count.index]["mobile_api_port"]
        vt_aspi_importer_repository: var.vt_aspi_importer_repository
        vt_aspi_importer_tag: var.istances[count.index]["vt_aspi_importer_tag"]
        vt_aspi_publish_group: var.istances[count.index]["vt_aspi_publish_group"]
        exchange: var.istances[count.index]["exchange"]
        vhost: var.istances[count.index]["vhost"]
        vt_in_template: file("${path.module}/files/vt_in_template.json")
        vt_out_template: file("${path.module}/files/vt_out_template.json")
        vt_state_template: file("${path.module}/files/vt_state_template.json")
        vt_announce_template: file("${path.module}/files/vt_announce_template.json")
        path_files_extension: ".geojson"
        default_avs_radius: var.istances[count.index]["default_avs_radius"]
        avs_id_prefix: var.istances[count.index]["avs_id_prefix"]
        max_number_avs_state: var.istances[count.index]["max_number_avs_state"]
        equidistant_distance: var.istances[count.index]["equidistant_distance"]
        aspi_tutors_url: var.istances[count.index]["aspi_tutors_url"]
        static_tutors_url: var.istances[count.index]["static_tutors_url"]
        category_id: var.istances[count.index]["category_id"]
      }
  )]
}