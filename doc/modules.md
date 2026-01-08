[Home](../README.md)

# Modules

In order to better manage and mantain the code, scripts are organized in Terraform modules, each with its own set of input variables and output data.
In a typical scenario no changes is required to any of this sub-module in order to manage a cloud instance.

In following paragraphs a description of each module is provided.

## AKS

This module is responsible of the creation and configuration of the Azure Kubernetes Service and generation of the configuration file with access details.

> In this module is possibile to change the linux admin and ssh_key file for the generation of the cluster nodes. Changing these paramenters will generate new nodes.

## Application Gateway

The main architecture, as described [here](./intro.md), includes an Azure Application Gateway with Web Access Firewal (WAF) controlled by a kubernetes Ingress Controller. 
This module contains all the logic and configuration needed in order to build and mantain this solution.
Some of the parameters that can be of interest here are detailed in the following table

| Parameter | Input description | Description |
|:---|:---|:---|
| *app_gateway_sku*  | *Azure instance sku* | Name of the Application Gateway SKU. Default Standard_v2 |
| *application_gateway_capacity*  | *AAG capacity* | Number of nodes to be installed |
| *aag_ingress_controller_helm*  | *AAG helm* | AAG helm package details. Includes repository and package version |

## Azure resources

This module defines some Azure specific resources, in particular the resource group that will contain the installation.

## Ingress Rules

Configures rules to be applied on AAG by means of the controller we installed in the cluster. All L7 routing is managed by means of *ingress rules* and relative annotations.
For a complete list of available annotations and relative documentation, please refer to the [specific documentaion]([)](https://azure.github.io/application-gateway-kubernetes-ingress/annotations/).

As an example the following code is provided

```
"kubernetes.io/ingress.class" = "azure/application-gateway"
"cert-manager.io/cluster-issuer" = "letsencrypt-prod"
"appgw.ingress.kubernetes.io/backend-path-prefix" = "/"
"appgw.ingress.kubernetes.io/ssl-redirect" = "true"
```

- *kubernetes.io/ingress.class*: informs the controller to apply the configuration to th azure application gateway
- *cert-manager.io/cluster-issuer*:  the ``cluster-issuer`` select the required SSL cert issuer (prod or staging)
- *appgw.ingress.kubernetes.io/backend-path-prefix*: rewrite url when forwarded to the backend
- *appgw.ingress.kubernetes.io/ssl-redirect*: redirect HTTP to HTTPs 

## K8s

Build and configure the Azure Kubernetes cluster. Relevant configurations are exposed in the root variables.

## Networking

The network configuration and IP addressing of the instance. IP subnet addressing and naming is not exposed to outer modules and can be changed directly in the module when strictly required.

## Observability

This module contains all relevant configuration for the observability of the system. A complete prometheus stack is installed following the [operator paradigm](https://github.com/prometheus-operator/prometheus-operator). For specific documentation please refer the the [helm repository](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md).
All relevant configurations have been exposed in the root module.

All elements in the configuration exposes prometheus metrics.

A number of customized grafana dashboards are available to be imported [here](https://github.com/quandopasso/grafana)


## Quandopasso™

This module contains the configurations of Quandopasso™ application services. A dedicated submodule has been created for each service while the main configuration os done in the root module.
All services are deploymed by means of *helm charts*, downloading the artifact images from the github Quandopasso™ repository.
Specific configuration of interest and package versions (*helm and service*) are directly exposed to the root module, so no configuration intervention should be required at this level.

## Rabbit

Configures a [rabbitMQ](https://www.rabbitmq.com/) instance as message broker of the quandopasso architecture. Admin pass is randomly generated on first install.

## TLS 

This modules install a letsencrypt certificate manager that can issue and update needed TLS certificates.
Consider that a quite strict *rate limit* is applied by letsencrypt (see [here](https://letsencrypt.org/docs/rate-limits/)), so avoid doing ripetitive testing on the same domain. As stated by the documentation _The main limit is Certificates per Registered Domain (50 per week)._
If you need to do testing on ingresses or instance creation, consider configuring in the ingress module, the staging instance instead of the production instance.


