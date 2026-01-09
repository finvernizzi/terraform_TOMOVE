# TOMOVE

SSH tunnel iomtegrato nel terraform per accedere al cluster AKS privato.
OSS: non copia automaticamente kubeconfig, quindi se si inizializa copiarlo dal cluster remoto nella cartella principoale (tomove)

## Porta 8080

Utilizzo nodeport cu igress controller


```sh
kubectl get nodes -o wide
NAME     STATUS   ROLES           AGE   VERSION    INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
qp-k8s   Ready    control-plane   32h   v1.30.14   100.105.151.38   <none>        Ubuntu 24.04.3 LTS   6.8.0-90-generic   containerd://1.7.28

# Port forward locale
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-ports 30370

```

## SSH Tunnel per k8s privato

Ho modificto il certificato di k8s per accettare 127.0.0.1 e localhost come nomi validi.
In questo modo posso fare un ssh tunnel verso il master k8s e accedere in locale da terraform (avendo anche modificato la configurazione scaricata in locale).
In terraform creo una risorsa null_resource che apre il tunnel ssh e la faccio dipendere da tutte le risorse k8s in modo che venga aperto prima di ogni operazione k8s.

> La creazione automatica del tunnel ssh funziona solo per la creazione del cluster. Nelle configurazion successive occerre creare manualmente il tunnel ssh prima di lanciare terraform.

Ad un certo punsto serve anche tulle alla 80 per chart o k8s.

## Comandi utili

> crictl: low level CLI per Container Runtime Interface (CRI) usato da kubelet. [doc](https://github.com/kubernetes-sigs/cri-tools)
> In pratica gira tutto su containerd, quindi crictl consente di vedere i container in esecuzione. K8s solo aggiunge lo strato di orchestrazione.

sudo crictl ps
sudo crictl ps -a | egrep 'etcd|kube-apiserver|kube-controller|kube-scheduler'
sudo ss -lntp | egrep '2379|6443' || true


> k9s 
> Utile per monitorare lo stato del cluster in tempo reale

### LOGS


> kubernetes logs
sudo journalctl -u kubelet -f

> systemd logs
sudo systemctl status containerd --no-pager

> controlplane 
sudo crictl ps -a | egrep 'kube-apiserver|kube-controller-manager|kube-scheduler|etcd'



kubectl client	kubectl -v=9
kube-apiserver	crictl logs kube-apiserver
kubelet	journalctl -u kubelet -f
etcd	crictl logs etcd

## Verifiche

# 1) what died?
sudo ss -lntp | egrep '2379|6443' || echo "NO LISTENER"

# 2) static pods state + restarts
sudo crictl --runtime-endpoint=unix:///run/containerd/containerd.sock ps -a | egrep 'etcd|kube-apiserver|kube-scheduler|kube-controller'

# 3) last kubelet errors around the time of death
sudo journalctl -u kubelet --no-pager -n 200

# 4) was etcd killed / stopped?
ETCD_CID=$(sudo crictl --runtime-endpoint=unix:///run/containerd/containerd.sock ps -a --name etcd -q | head -n 1)
echo "ETCD_CID=$ETCD_CID"
sudo crictl --runtime-endpoint=unix:///run/containerd/containerd.sock logs "$ETCD_CID" | tail -n 200


# Restart k8s
sudo systemctl restart containerd
sudo systemctl restart kubelet


sudo ss -lntp | egrep '2379|6443' || echo "NO LISTENER"
sudo crictl --runtime-endpoint=unix:///run/containerd/containerd.sock ps -a | egrep 'etcd|kube-apiserver|kube-scheduler|kube-controller'
kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes
kubectl --kubeconfig=/etc/kubernetes/admin.conf -n kube-system get pods -o wide


## Customer slicing (Multitenant)

Al momento tutti i servizi specifici (cache, ad esempio) utilizzano lo stesso vhost/user/pass su rabbitMQ. Per separarli occorre definire anche le policy per avere chi pubblica su vhost multipli, pass multiple (secret) ecc. In questa versione utilizziamo un solo vshost: questo non limita la sicurezza (vhost, user e pass sono definiti), ma riduce la separazione tra i diversi contesti.

In alcuni casi in cui si hanno installazioni multiple (una per dominio, come per la cache). In questi casi, dove possibile, viene utilizzato un namespace dedicato per evitare sovrapposizioni di risorse.

> Alcuni servizi hanno istanze multiple, una per tenant (es la cache). Sono configurazionie separate il tenant ed il namespace. Posso quindi avere, ad esempio, istanze multiple di una cache, tutte nello stesso namespace o in namespace distinti. La separazione di namespace è utile solo per ridurre affollamento di un singolo namespace.


La generazione di componenti multiple per tenant (es cache) è tipicamente fatta da terraform. Questo consente ad un helm chart di ragionare per sigolo tenant senza complicazioni dovute alla multitenancy. é però importante che nel singolo helm chart non ci siano possibili sovrapposizioni (e.g. nomi)


## Appunti
Gestione infrastruttura AK8s con terraform

https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

traformare yaml in json [vedi](https://github.com/hashicorp/terraform-provider-kubernetes-alpha) e [qui](https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform)


> Per la gestione della Applications, andare in Active Directory/ App registrations. Sulla singola app si possono gestire i secret

## Certificati

Nel caso si dovesse sostituire un'istanza completa di QP con certificato attivo:
- eliminare i cluster
- fare prove in staging
- passare il cluster creato da staing a prod ed aspettare qualche minuto

> Di solito nel cert-manager si vedono degli errori, ma si riallinea.

## Token di accesso del service principal

Per accedere e creare il cluster utilizziamo un service principal con secret.
I secret hanno una scadenza, quindi verificare periodicamente che siano validi.

Quando scadono è sufficente aggiornarli nelle variabili di ambiente, ma questo causa **un redeploy del cluster** 
Tutto torna attivo nel giro di circa 30 minuti senza apparente perdita di dati.

## Linter

Utilizzo di tflint da capire
https://opensourcelibs.com/lib/tflint

## Controllo statico del codice terraform

- [Checkov](https://www.checkov.io/4.Integrations/Terraform%20Scanning.html)
  ```sh
  terraform show -json test.eu.plan | jq '.' > test.eu.plan.json
  checkov -f test.eu.plan.json
  ```


## Dashboard grafana

Al momento una sola config map contiene tutte le dashboard. Dal momento che ci sono limiti nel numero massimo di caratteri di una configmap, in futuro occorrerà capire come configurare config.map multiple. [Vedi](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

## Registry

Anche il container registry va creato. (Vedi)[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/**container_registry**]

### HELM

I chart helm vengono caricati su azure Storage account (vedi Readme su charts). Per funzionare deve essere attivo chartmuseum su doc.quandopasso.com



### HELM - CHARTMUSEUM

[doc](https://chartmuseum.com/docs/#installation)

> Su doc.quandopasso.com è definito questo script di avvio

```sh
export AZURE_STORAGE_ACCOUNT=qphelmsa
export AZURE_STORAGE_ACCESS_KEY=*****
chartmuseum --debug --port=8080 \
  --storage="microsoft" \
  --storage-microsoft-container="quandopasso" \
  --storage-microsoft-prefix=""

```

> Se non vede nuova release, cancellare index-cache.yaml su Azure storage e far ripartire

## DNS

Negli script terraform gestiamo solo il record A ``azurerm_dns_a_record`` pertanto la zona deve già esistere in Azure.
Nel caso si può anche eliminare, ma non succede nulla se la si importa.
>Il problema potrebbe essere se più istanze utilizzano lo stesso nome di dominio (mai provato), **evitare** 


## Accesso

> Al fine di avere terraform funzionante, occorre avere un login attivo. Per verificarlo
> ```sh
> # Check if we have a valid token
> az account get-access-token
> # If not active
> az login
> ```


Vedi https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/servi**ce**_principal_client_secret

Per la creazione di un Service Principal

```sh
az ad sp create-for-rbac --skip-assignment --name quandopassoAKSDevCluster
```

> Questo serviceprincipal si può vedere in [Azure Active Directory -> App registrations](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps)

Ho creato un service principal per la gestione del cluster.

I valori vanno inseriti in ENV per le variabili

```terraform
variable "client_id" {}
variable "client_secret" {}
```
Ad esempio

```sh
export TF_VAR_client_id=1111111111111
export TF_VAR_client_secret="lkajlskjdflksjdfl"
```

> Per vedere i dettagli del service principal
> ```sh
> az ad sp list
> az ad sp show --id ...
> ```

> Per reset della pass
> ```sh
> az ad sp credential reset --name 33f6161a-7506-4389-804c-77e1fd2dd78d
> ```

## Helm

[Luglio 2022]
I chart sono su blob azure, esposti da chartmuseum. Ricordarsi di farlo partire su doc.quandopasso.com

>Al momento i chart sono pubblici. Inserire token da dare a chartmuseum

**VERIFY**
Helm consente di fare una verifica sulla [validità del package](https://helm.sh/docs/topics/provenance/). Il provider helm di terraform supporta questo controllo. Inserire la verifica.

### Subchart HELM

Nel caso di chart che contengono dei sub-chart (es. observability stack), [vedi])(https://helm.sh/docs/chart_template_guide/subcharts_and_globals/) per configurare i values dei sub.chart


### Eliminazione chart esternamente a terraform

C'è un baco (note)[https://github.com/hashicorp/terraform-provider-helm/issues/662] per cui se viene rimosso un chart helm all'esterno di terraform, poi on si riesce più a gestirlo con terraform.
Workaround

```sh
# Lista degli stati conservati da terraform
terraform state list
# Rimozione dello stato con problemi
terraform state rm helm_release.cache
# A questo punto si può procedere come al solito (plan, apply)
```

### Error: "cache" has no deployed releases

Si tratta di un controllo di helm sullo stato dei deployment. Nel caso non siano andati a buon fine può produrre questo errore.
[Vedi](https://jacky-jiang.medium.com/how-to-fix-helm-upgrade-error-has-no-deployed-releases-mystery-3dd67b2eb126), soluzione per HELM 3.


## Accesso al cluster

**ATTENZIONE** dopo aver creato il cluster terraform salva sul file ``.azurek8s.config``(nella cartella in cui si lancia lo script) un file per kubectl con le configurazioni di accesso al cluster.
Dopo la creazione del cluster occorre quindi definire la env var

```sh
export KUBECONFIG=.azurek8s.config
```

Terraform (in particolare ``azurerm``) genera tutto il necessario per accedere direttamente al cluster ([vedi](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks#test-the-kubernetes-cluster))

```sh
echo "$(terraform output kube_config)" > ./azurek8s
export KUBECONFIG=./azurek8s
kubectl get nodes
```

### Problemi con il provider gavinbunney/kubectl

Dopo alcune modifiche è successo che il provider ``gavinbunney/kubectl`` abbia dato un errore come se non riconoscesse più l'host cui accedere, andado quindi su 127.0.0.1, come nell'esempio che segue

```sh
 Error: failed to create kubernetes rest client for read of resource: Get "http://localhost/api?timeout=32s": dial tcp 127.0.0.1:80: connect: connection refused
│
│   with module.application_gateway.kubectl_manifest.azureassignedidentities,
│   on ../modules/application_gateway/main.tf line 33, in resource "kubectl_manifest" "azureassignedidentities":
│   33: resource "kubectl_manifest" "azureassignedidentities" {
```

Non mi è chiarissimo perchè, ma in questi casi si può provare a modificare il valore di ``load_config_file`` nella configurazione del provider, come discusso [qui](https://github.com/gavinbunney/terraform-provider-kubectl/issues/63). Nel mio caso ha funzionato commentando la configurazione, ossia utilizzando il default del provider.

## RABBIT

Per aggiungere admin [vedi](https://gist.github.com/sdieunidou/1813409ddfd0185c82c7)

Configurare dinamicamente la configmap ``definitions``

### Management plugin

- abilito management_plugin
- in terraform apro port forward con local-exec
- mi collego attraverso port forward

Questo approccio mi consente di configurare completamente rabbit direttamente da terraform
Da capire se è l'approccio più sicuro dal momento che devo lasciare attivo il plugin di management

Da capire:
- definire utente con permessi necessari in fase di installazione helm. [Vedi](https://www.rabbitmq.com/management.html#permissions)

[Vedere](https://www.rabbitmq.com/production-checklist.html) per messa in produzione


## Persistent volumes

I dischi di persistance sono creati dinamicamente indicando classe e dimensione.
I dischi di ``atlante`` sono creati
  - in azure resource viene ecreato lo Storage Account (e salvate in secret ad-hoc le credenziali)
  - in aks viene configurato il persistentvolume
  - atlante crea il claim presupponendo che sia tutto pronto


## Modifica tipo AAG

- Cambiando i parametri nello sku (da Standard_v2 a Standard) da errore di parametri non validi.
- AAG standard richiede un IP pubblico con sku basic. Lo svantaggio principale è che sono 'Are open by default. Network security groups are recommended but optional for restricting inbound or outbound traffic.'. [Vedi](https://docs.microsoft.com/en-us/azure/virtual-network/public-ip-addresses). Allocation_method diventa **dynamic**
- AGIC non supporta app gateway v1. 
   ```sh
   F0724 06:30:05.149831       1 main.go:193] App Gateway SKU Tier Standard is not supported by AGIC version 1.3.0/7055fe28/2020-11-30-23:26T+0000; (v0.10.0 supports App Gwy v1)
   ```
   Passaare ad una versione così vecchia potrebbe richiedere di cambiare troppe congirazioni

**RITORNO A standard_v2_
- Eliminato IP
- Eliminato RR A nella zona DNS (dopo 5 min tutto a posto nel DNS)
- fatto salire AAG
- Eliminato ingress
- Ricreato ingress