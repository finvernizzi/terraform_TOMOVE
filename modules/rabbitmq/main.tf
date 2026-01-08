/**
* For each user defined in rabbitmq_users generate a random pass
* - if user is THE admin (only one can be admin) use it and its pass as default rabbitmq user
* - store each pass in the rabbit-users secret (services will access this info from there)
* - generate the definitions.json config file for rabbitmq
*
* Since password is a resource and we can generate a number only with the count operator we will access them by index.
* This is the reasone we need to use expressions like random_password.users_pass[index(keys(var.rabbitmq_users), name)].result
*   - retrive the index of the name of a user in the var.rabbitmq_users and use it as index for the generated password
**/

locals {
  # This is a map, but only the first element is considered
  admin_users = {
    for name, user in var.rabbitmq_users : name => user
    if user.is_admin
  }
  regular_users = {
    for name, user in var.rabbitmq_users : name => user
    if !user.is_admin
  }
  rabbitmq_passwords  = {
    for name, user in var.rabbitmq_users : name => random_password.users_pass[index(keys(var.rabbitmq_users), name)].result
  }
  # redefine name and pass of admin for semplicity
  admin_user          = keys(local.admin_users)[0]
  admin_pass          = local.rabbitmq_passwords[keys(local.admin_users)[0]]
  # Add root to list of vhosts
  vhosts              = "${concat(var.rabbitmq_vhosts, ["/"])}"
}

/** Generates a random pass for each user defined */
resource "random_password" "users_pass" {
  count            = length(var.rabbitmq_users)
  length           = 16
  special          = false
  override_special = "_%@#"
}

/** RABBITMQ Helm CHART */
resource "helm_release" "rabbitmq" {
  name       = "rabbit"

  repository = "https://9a75302080758cac2cf574cdb56ed67bade16784@raw.githubusercontent.com/finvernizzi/charts/terraform/packages"
  chart      = "rabbitmq"
  version    = var.chart_version
  create_namespace = true
  namespace = var.namespace
  cleanup_on_fail = true

  values               = [ 
    templatefile(
      "${path.module}/values.template.yml", 
      {
        namespace: var.namespace
        environment: var.environment
        tag: var.rabbitmq_helm_version
        service_monitor_release: var.service_monitor_release
        domain: var.domain
        default-user: local.admin_user
        default-password: local.admin_pass
      }
  )]
}
# RABBITMQ CONFIGURATION

# Save to local file
resource "local_sensitive_file" "rabbitmq_credentials" {
    content   =  <<EOT
    user: ${local.admin_user}
    password:${local.admin_pass}
    EOT
    filename            = ".rabbitmq"
    file_permission     = 0400
}
/**
* Stores users pass in a secret for services to acces them
* Since in K8s we cannot read a secret outside our namespace, this secret is created in each namespace required by users_namespaces.
**/
resource "kubernetes_secret" "users" {
  count = length(var.users_namespaces)
  metadata {
    name = "rabbitmq-users"
    namespace = var.users_namespaces[count.index]
  }
  data = {
    for name, user in var.rabbitmq_users : name => "${random_password.users_pass[index(keys(var.rabbitmq_users), name)].result}"
  }
}



/** 
* Creates the definitions file from a template
* Here we can completely configure rabbitmq (vhosts, users, permissions, queue, ...)
*
* 
* --- USER PERMISSIONS ---
* For each user define an array of permissions with [<read>, <write>, <configure>] for each vhost defined
*
* We use the HCL [for loop construct](https://www.terraform.io/docs/language/expressions/for.html#result-types) fo generating objects.
* 
*/
resource "kubernetes_config_map" "definitions" {

  metadata {
    name      = "definitions"
    namespace = var.namespace
  }
  data = {
    "definitions.json" =  templatefile(
      "${path.module}/definitions.json.tpl", 
      { 
        environment        = "${var.environment}"
        users         = {
          for name, user in var.rabbitmq_users : name => local.rabbitmq_passwords[name]
        }
        permissions   = {
           for name, user in var.rabbitmq_users : name => 
              (user.is_admin) ? 
              {
                for vhost in local.vhosts : vhost => [".*",".*",".*"]
              }:{
                for vhost in var.rabbitmq_vhosts : vhost => [".*",".*",".*"]
              }
        },
        vhosts         = local.vhosts,
        admin_user     = local.admin_user
       }
      )
  }
}