// @TODO: ssh public key
resource "azurerm_kubernetes_cluster" "k8s" {
    name                                = var.cluster_name
    location                            = var.location
    resource_group_name                 = var.resource_group_name
    dns_prefix                          = var.dns_prefix
    // enable k8s network policy enforcement (gatekeeper)
    # azure_policy_enabled                = true
    http_application_routing_enabled    = false
    # Allow access only from defined ip addresses or ranges
    # api_server_authorized_ip_ranges  = [var.api_server_authorized_ip_ranges]
    kubernetes_version  = var.k8_version
    
    # The linux_profile record allows you to configure the settings that enable signing into the worker nodes using SSH.
    # https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks#5-define-a-kubernetes-cluster
    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = var.node_pool_name
        node_count      = var.node_count
        vm_size         = var.vm_size
        os_disk_size_gb = var.aks_agent_os_disk_size
        vnet_subnet_id  = var.kubesubnet_id
        max_pods        = var.max_pods
    }
    # [See](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    network_profile {
        network_plugin     = "azure"
        dns_service_ip     = var.aks_dns_service_ip
        # docker_bridge_cidr = var.aks_docker_bridge_cidr
        service_cidr       = var.aks_service_cidr
        # --------------------------------------------
        # --- Per avere uno specifico IP in uscita ---
        // load_balancer_profile {
        //     outbound_ip_address_ids = [var.public_ip_id]
        // }
        # --------------------------------------------
    }
    # https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
    # key_vault_secrets_provider {
    #     secret_rotation_enabled = false
    # }

    tags =                  var.tags
}

resource "local_file" "k8s_config" {
    content             = azurerm_kubernetes_cluster.k8s.kube_config_raw
    filename            = ".azurek8s.config"
    file_permission     = 0400
}