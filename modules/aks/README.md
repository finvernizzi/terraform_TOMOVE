# Azure Kubernetes

To see documentation about kubernetes support in Azurre see [here](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli).

From cli

```sh
az aks get-versions --location westeurope
```

## Migration policy

A migration policy from a Quandopasso instance running on an outdated AKS release to an updated AKS cluster should be defined.
> il problema è tipicamente con application gateway, nei ``kubectl_manifest`` del main che hanno problemi di versione con aggiornamento della versione di K8s.