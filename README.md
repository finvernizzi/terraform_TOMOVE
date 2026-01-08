<!-- title: Quandopasso cloud infrastructure -->

> This is the main Quandopasso environment infrastructure configuration
> It does not include TCS, that is a in a separate repository


# Quandopasso™ infrastructure management

This is a [Terraform](https://www.terraform.io/) repository, containing all the configuration and logics needed to build a complete installation of a [Quandopasso™](https://www.quandopasso.com) cloud instance.
The configuration includes
- Azure configuration (*resource group, azure identities, ...*)
- Networking creation and configuration (*virtualNetworks, load balancer, AAG, public IP, DNS, ...*)
- kubernetes creation and configuration
- Security (*Identities, firewall, https certificate acquisition and configuration, ...*)
- Observability (*Promethes, Graphana*)
- Quandopasso™ specific services
  
Please refer to following instruction to build or configure a Quandopasso™ cloud instance

For an introduction on the Quandopasso architecture, please read [this](./doc/intro.md);

## AZ token

If the refresh token has expired

```sh
az login --scope https://graph.microsoft.com/.default
```

## Required software

All the documentation and code in this repository has been tested using terraform.

```sh
❯ terraform -v
Terraform v1.0.4
on darwin_amd64
```

## Required input parameters

Terraform scripts defined in this repository will access Azure platform by means of ``Service Principal`` with a ``Client Secret``. ([see](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) for details).
In order to run the Terraform scripts, user needs to provide following parameters in [one of the accepted](https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables) terraform variable input.


| Parameter | Input description | Description |
|:---|:---|:---|
| *client_id*  | *Object ID of the service principal* | This is the application (client) ID the terraform scripts should work with in the AAD |
| *client_object_id* | *The azure application OBJECT ID* | Application (client) Object ID owner of the installation|
| *client_secret* | *The azure application ID* | Application (client) secret to prove identity on AAD|
| *subscription_id* | *The azure application secret* | The Azure subscription id scripts should work with|
| *aks_service_principal_object_id* | *Object ID of the service principal* | Service principal. Use azure client to obtain it. E.g. ```az ad user show --id admin.fin@quandopassocom.onmicrosoft.com --query objectId --out tsv```|

For a description of available configuration parameters please refer to [Configuration](#configuration)

>Example of CLI input
```bash
terraform plan -out=./dev1.plan
var.aks_service_principal_object_id
  Object ID of the service principal.

  Enter a value: ***

var.client_id
  The azure application ID

  Enter a value: ***

var.client_secret
  The azure application secret

  Enter a value: ***

var.subscription_id
  The azure subscription ID for this deployment

  Enter a value: ***
```

## AKS cluster access

The Kubernetes cluster creation scipt generates a standard [Kubernetes config file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) to store access information. The file is created in the folder the script is running, and is named by default ``.azurek8s.config``. 

```sh
export KUBECONFIG=./.azurek8s.config
```
As described in the specific documentation, the name of the file can be changed in the configuration of the ``aks`` module.

## Create a new instance

All logic and data are grouped in dedicated and specific terraform modules and all these modules need to be configured and run in a specific way.
A complete working template is provided in the folder ``test.eu`` that will produce a new instance.

> Before starting the creation of a new infrastructure from scratch, **double check** the folder you are in does not contain
> - a terraform state file or a terraform state backup file
> - a previously generated kubernetes config file (_.azurek8s.config_)
> - a previously generated grafana credentials file (_.grafana_)
> - a previously generated rabbitmq credentials file (_.rabbitmq)
> - any previously generated terraform state file
> **Be sure to have a backup of these files before deleting them**

The suggested way to run the scripts, is to copy the folder and modify the newly created folder, as shown in following example

```bash
# Some helping env vars
export FOLDER_NAME=<whatever_name_you_want>
export INSTANCE_FOLDER_NAME=<whatever_name_you_want>
# Clone the repository
git clone https://github.com/quandopasso/terraform.git $FOLDER_NAME
# Move to the newly created folder
cd $FOLDER_NAME
# Copy the template to a new folder
cp -r test.eu $INSTANCE_FOLDER_NAME
# Move to the newly created folder
cd $INSTANCE_FOLDER_NAME
## -----------------------------------------------------##
## --- CHANGE ALL NEEDED CONFIGURATION              --- ##
## -----------------------------------------------------##
## -----------------------------------------------------##
## --- ADD VAULT FILES                              --- ##
## --- The __ROOT__ folder is $INSTANCE_FOLDER_NAME --- ##
## ---                                              --- ##
## -----------------------------------------------------##
# Init terraform
terraform init
# Run terraform plan
terraform plan -out=./test.plan
# Apply the new plan
terraform apply "./test.plan"
# Use the K8s cluster access info
export KUBECONFIG=`pwd`/.azurek8s.config
# Work with bubectl as usual
kubectl get nodes
```

> Upon successfull creation of the system, you will find some new files in your folder, containing newly created credentials
> - *.azurek8s.config* the certificate to access the kubernetes cluster
> - *.grafana* contains credentials to access the grafana instance
> - *.rabbitmq* contains admin credentials of the rabbitmq instance


## AUTH0

Controlboard authentication is done by means of OAUTH on an external service (auth0.com).


## Configuration

Configuration of the instance can be done by means of input variables, defined in the main script or in specific module configurations.
Therefore, configuration parameters can be grouped in two distinct categories:
- instance configuration parameters
- module parameters

The former group of parameters is related to a specific installation, needed to have the exact configuration required and in tipical scenarios are the only parameters modified before an installation. These parameters are all defined in the main ``variables.tf`` file, directly in the instance dir.
The second group of parameters is specific to the way the system works and internal configuration and interaction between modules. These parameters are defined in the ``variables.ts`` files specific of each module and, in normal scenarios, *should not be modified*.

> For a complete list of available instance parameters, please refer to [parameters documentation](./doc/instance_params.md)
> Documentation of available modules can be found [here](./doc/modules.md)

## Secret management

The installation and configuration of a complex K8s cluster with networking, accessories services and application services requires a number of secret to be managed.
In this installation all secrets are kept in **local file system** in a specific folder in each module, named ``vault``. This folder is exluded by git in the ``.gitignore`` configuration file.
Future release can require a centralized secret management to replace the file system based solution.

The following table is a list of parameters managed by vault folder 

| Module | File Name | Secret | Description |
|:---|:---|:---|:---|
| *root*  | ``smtp.json`` | *smtp_server* | SMTP server the system will use to send emails |
| *root*  | ``smtp.json`` | *smtp_username* | SMTP username the system will use to send emails | 
| *root*  | ``smtp.json`` | *smtp_password* | SMTP password the system will use to send emails | 
| *quandopasso*  | ``acr-prod.json`` | *user* | Azure Container Registry user |
| *quandopasso*  | ``acr-prod.json`` | *password* | Azure Container Registry password | 
| *quandopasso*  | ``acr-prod.json`` | *server* | Azure Container Registry url | 
| *quandopasso*  | ``**helm**_repo.json`` | *url* | Quandopasso Helm repository with credentials | 
| _quandopasso_/*cache*  | ``cache.secrets.json`` | *queue_user* | The AMQP user | 
| _quandopasso_/*cache*  | ``cache.secrets.json`` | *queue_password* | The AMQP password | 
| _quandopasso_/*cb-api*  | ``cb-api.secrets.json`` | *sign* | Should we sign all vsign? |
| _quandopasso_/*cb-api*  | ``cb-api.secrets.json`` | *sign_algorithm* | The algorithm for signing vsigns |
| _quandopasso_/*cb-api*  | ``cb-api.secrets.json`` | *jku* | The path of the url where public key is published |
| _quandopasso_/*cb-api*  | ``cb-api.secrets.json`` | *kid* | Key ID | 
| _quandopasso_/*cb-api*  | ``cb-api.secrets.json`` | *queue_user* | The AMQP user |
| _quandopasso_/*cb-api*  | ``cb-api.secrets.json`` | *queue_password* | The AMQP password |
| _quandopasso_/*cb-api*  | ``cb-api.secrets.json`` | *cert_file* | The cert file to sign controlboard generated vsigns | 
| _quandopasso_/*controlboard*  | ``controlboard.secrets.json`` | *queue_user* | The AMQP user | 
| _quandopasso_/*controlboard*  | ``controlboard.secrets.json`` | *queue_password* | The AMQP password | 
| _quandopasso_/*mobile-api*  | ``mobile-api.secrets.json`` | *jws_iss* | JWT issuer (deprecated) | 
| _quandopasso_/*mobile-api*  | ``mobile-api.secrets.json`` | *jws_sec* | JWT secret (deprecated) |
| _quandopasso_/*mobile-api*  | ``mobile-api.secrets.json`` | *token* | The token of the customer to access the API (no_token disables token check) |
| _quandopasso_/*persistance*  | ``persistance.secrets.json`` | *db_user* | User to access DB | 
| _quandopasso_/*persistance*  | ``persistance.secrets.json`` | *db_password* | Password to access DB | 
| _quandopasso_/*persistance*  | ``persistance.secrets.json`` | *queue_user* | The AMQP user |
| _quandopasso_/*persistance*  | ``persistance.secrets.json`` | *queue_password* | The AMQP password |
| _quandopasso_/*terminals-api*  | ``terminals-api.secrets.json`` | *token* | The token of the customer to access the API (no_token disables token check) |
| _quandopasso_/*terminals-api*  | ``terminals-api.secrets.json`` | *influx_token* | TSDB (influx) token |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *domain* | The domain |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *jws_iss* | JWT issuer (deprecated) |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *jws_sec* | JWT secret (deprecated) |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *client-id* | Oauth client ID |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *auth0-domain* | Auth0 domain |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *client-secret* | Oauth client secret |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *audience* | Auth0 audience |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *pass* | Viasuisse API pass |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *account* | Viasuisse API account |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *importer_cert_file* | Cert file to sign vsigns |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *importer_jku* | Certificate Key Url |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *importer_kid* | Certificate Key ID |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *importer_sign* | Should we sign vsigns? |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *importer_sign_algorithm* | Sign alghoritm |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *queue_user* | The AMQP user |
| _quandopasso_/*viasuisse_import*  | ``importer.secrets.json`` | *queue_password* | The AMQP password |

## DNS

The creation scripts need to use a DNS name delegated to Azure infrastructure.
The name will be created if not available on an already configured zone delegated to Azure.
If the name is already configured on azure you will obtain an error similar to following example

```sh
Error: A resource with the ID "/subscriptions/8a0bdc85-cc1c-4894-9acd-aedeec5a3eaa/resourceGroups/defaultresourcegroup-weu/providers/Microsoft.Network/dnszones/quandopasso.eu/A/dev" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_dns_a_record" for more information.

  on ../modules/networking/main.tf line 52, in resource "azurerm_dns_a_record" "main_domain":
  52: resource "azurerm_dns_a_record" "main_domain" {

```

To solve the problem import it, as shown in following script ([see](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record#import) for documentation)

```sh
# Example of import of the DNS zone
terraform import module.networking.azurerm_dns_a_record.main_domain /subscriptions/8a0bdc85-cc1c-4894-9acd-aedeec5a3eaa/resourceGroups/defaultresourcegroup-weu/providers/Microsoft.Network/dnszones/quandopasso.eu/A/dev
```

## HTTPS Certificate management

The system is configured to _automatocally_ generate https valid certificates by means of interactions with [letsencrypt](https://letsencrypt.org/) certificate authority. Please refer to the specific documentation [here](./modules/tls/Readme.md) for more details.

## EMAILS

Grafana can send emails when specific alarms are triggered, so SMTP configuration is needed.
In order to activate sending of alert message a valid SMTP configuration is needed. 
[See secret management](Secret-management) for a list of parameters avaiòable for mail configuration.

## Observability

The configuration includes a set of tools to monitor the running system. [Refer to](./modules/observability/Readme.md) for more details.

Due to a race in the configuration of the service, a change on the kubernetes configuration after install can be required in order to access the grafana dashboard.

After the system has been installed, check ``observability-grafana`` configmap, in ``observability`` namespace. If it does not contain following lines, adde them

```ini
[server]
domain = <THE DOMAIN CONFIGURED IN var.domain>
root_url = https://<THE DOMAIN CONFIGURED IN var.domain>/<grafana_path configured in var.grafana_path>/
serve_from_sub_path = true
enable_gzip: true
[smtp]
enabled = true
host = <your host>
user = <your user>
# If the password contains # or ; you have to wrap it with trippel quotes. Ex """#password;"""
password = <SMTP password>
;cert_file =
;key_file =
;skip_verify = false
from_address = <your from address>
from_name = <your from name>
# EHLO identity in SMTP dialog (defaults to instance_name)
;ehlo_identity = dashboard.example.com
```

After the change is in place, restart the pod named ``observability-grafana-xxx``. You can simply remove the pod and K8s will start a new one with the desired configuration. The grafana dashboard should be now accessible.
> Dashboard username and password will be available in the secret ``observability-grafana``


## VANITY URL

1- Register a resource in DNS pointing to the cluster public IP. It is suggested to register a CNAME pointing to the A record of the public IP
2- Add the vanity to the configuration. This will create the HTTP routing and issue a new certificate

