[Home](../README.md)

| Parameter | Input description | Description |
|:---|:---|:---|
| *client_id*  | *Object ID of the service principal* | This is the application (client) ID the terraform scripts should work with in the AAD |
| *client_object_id* | *The azure application OBJECT ID* | Application (client) Object ID owner of the installation|
| *client_secret* | *The azure application ID* | Application (client) secret to prove identity on AAD|
| *subscription_id* | *The azure application secret* | The Azure subscription id scripts should work with|
| *aks_service_principal_object_id* | *Object ID of the service principal* | Service principal. Use azure client to obtain it. E.g. ```az ad user show --id admin.fin@quandopassocom.onmicrosoft.com --query objectId --out tsv```|
| *node_count*  | *K8s cluster nodes* | Number of nodes to be created in the K8s cluster node_pool|
| *max_number_of_pods_per_agent*  | *Max number of pods for each node* | The max number of pods a node in the cluster can support. Default to 30 if not defined in the main variables file |
| *k8_version*  | *K8s version* | Version of K8s to be installed. Changing this will require regression test on the installation.  |
| *vm_size*  | *Virtual machine type* | Please [refer to](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-vm-sizes?view=azs-2102) for a list of available configurations |
| *node_pool_name*  | *Node pool name* | Name of the pool of nodes to be installed in the K8s cluster |
| *dns_prefix*  | *AKS DNS* | Optional DNS prefix to use with hosted Kubernetes API server FQDN. This is not the DNS zone exposed to Internet|
| *azcr_pullimage_secret_name*  | *Container registry secret* | Name of the secret storing credentials to pull images from AZ container registry. |
| *cluster_name*  | *Cluster name* | Name of the AKS cluster |
| *location*  | *Azure region* | The Azure region where te cluster will be deployed. [See](https://azure.microsoft.com/en-us/global-infrastructure/geographies/) for available values |
| *environment*  | *Environment* | An environment tag of the installation. This is applied to a number of naming templates (e.g. the resource group, tags, ecc.) |
| *domain*  | *Domain* | The Quandopasso Domain the installation will serve. A domain is the internal ID for a slice of the service |
| *customer*  | *Customer* | A label for resource tags.|
| *common_namespace*  | *Common k8s namespace* | Namespace were all services shared between slices are placed.|
| *observability_namespace*  | *Observability namespace* | K8s namespace for observability pods |
| *certmanager_namespace*  | *Certification manager namespace* | K8s namespace to be assigned to certification pods (letsencrypt)|
| *grafana_path*  | *Grafana url* | The path url where the grafana service is exposed|
| *azcr_prod_host*  | *Azure Container Regitry - TEMP * | **Temporary** The Azure Container Registry address. Container artifacts will be downloaded from this registry |
| *helm_repository*  | *Quandopasso Helm repository* | Where Quandopasso specific helm packages are stored |
| *azcr_prod_pullimage_secret_name*  | *Secret of the artifact registry* | This secret will store the secret to access the artifact repository |
| *storageSecretName*  | *Secret of the storages* | This secret stores the info to access the storages |
| *aag_controller_identity*  | *AAG identity name* | Name of the identy to manage AAG by means of an ingress controller |
| *dns_zone*  | *DNS zone* | The zone quandopasso we will serve the system from. |
| *host_name*  | *Host name* | Name of the host, in the ``dns_zone``, we will serve the system from|
| *dns_zone_resource_group_name*  | *DNS resource group* | The resource group where the DNS zone is registered |
| *quandopasso_services*  | *Microservices versions and specific configurations* | Complete list of microservices versions, with related helm packages versions, and specific configurations |


