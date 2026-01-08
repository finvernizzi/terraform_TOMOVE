# Azure and terraform

Per utilizzare le credenziali memorizzate in un file di input ([vedi](https://developer.hashicorp.com/terraform/language/values/variables#using-input-variable-values)) eseguire ``terraform apply -var-file="testing.tfvars"
``

> ``terraform plan -out=./westeurope-02.plan -var-file="azure_credentials.tfvars"``

IN ALTERNATIVE utilizzare env vars.

Per informazioni utili su [Service Principals](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)

Per[ autenticazione terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash)


## Reset secret del service principal

> [Vedi](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)


```sh

az ad sp credential reset --id 33f6161a-7506-4389-804c-77e1fd2dd78d
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli

az ad sp credential reset --id 9845bf4c-342c-4da5-9485-d04bff1f2305
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli


```


## Creazione nuovo service principal

```sh
# Create the service principal
az ad sp create-for-rbac --name qp-terraform-we2 --role Contributor --scopes /subscriptions/8a0bdc85-cc1c-4894-9acd-aedeec5a3eaa
Creating 'Contributor' role assignment under scope '/subscriptions/8a0bdc85-cc1c-4894-9acd-aedeec5a3eaa'
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli

```