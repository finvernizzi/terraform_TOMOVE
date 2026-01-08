# Azure Application Gateway

https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-aks-applicationgateway-ingress#create-the-kubernetes-cluster


## Azure Application Gateway Ingress Controller

Consente di avere un ingress controller che pilota il AAG in modo da avere solo la parte di controllo nel cluster ed il carico di traffico su AAG.
Attenzione ai permessi: utilizza gli MSI (manaaged service identity) ed installa dei pod che danno i permessi di accesso all'identity creata per modificare la configurazione del AAG.

https://azure.github.io/application-gateway-kubernetes-ingress/

## Multinamespace

Se non si indicano i namespace da monitorare nella configurazione del controller, è multi-namespace.
https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-aks-applicationgateway-ingress#next-steps

## Controller / ingress

Occorre installare l'ingress controller secondo quanto indicato qui

https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/setup/install-existing.md

Attenzione ad installare tutti gli elementi necessari!

Per ingress rules di esempio vedi Vedi esempio in aag_test (applicazione di prova). Esempio (in namespace qualsiasi)
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test1
  namespace: test
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
spec:
  rules:
  - http:
      paths:
      - path: /prova1
        backend:
          serviceName: aag-api
          servicePort: 80
```

### Helm config (del controller)

Vedi esempio in aag_test (applicazione di prova)


## IAM (del controller)

Attenzione ai permessi. In particolare se non viene su controllare i pod che iniziano con MIC: sono i pod che gestiscono IAM verso AAD per dare accesso a AAG (Managed Service Identity: MSI).
Nel caso si può intervenire da web gui e aggiungere i permessi che mancano. Da capire come cablare in terraform

Manca sempre il permesso del service principal sulla MSI generata. Attenzione che nella visualizzazione il SP non è mostrato direttamente: **indicare il nome** .

## HTTPS

AAG può lavorare in TLS-termination. Per la gestione dei certificati si può utilizzare letencrypt come descritto [qui](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-letsencrypt-certificate-application-gateway). Rimane da capire come automatizzare la configurazione di questa parte dal momento che non sembra si possano configurare i CRD con terraform.
La cosa migliore sarebbe riuscire a creare un helm chart che fa tutto, da richiamare in terraform.


## Ricerche per application id

[Vedi](https://stackoverflow.com/questions/65599704/how-to-find-an-identity-by-client-id-in-azure)