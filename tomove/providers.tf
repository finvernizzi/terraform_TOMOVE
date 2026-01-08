# Configure required providers
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "null" {}

# provider "azurerm" {
#   features {}
# }


provider "helm" {
  kubernetes = {
    config_path      =  "${path.root}/.kubeconfig"
    load_config_file = true
    insecure         = true
  }
}

provider "kubectl" {
  config_path      = "${path.root}/.kubeconfig"
  load_config_file = true
  insecure         = true // To use ssh tunnel
}

provider "kubernetes" {
  host        = "https://127.0.0.1:6443"
  config_path = "${path.root}/.kubeconfig"
}
