# Postgresql

Modulo per la creazione di un db psql Azure.

Per connessioni (user e pass) di prova creare questo pod (vedi file in questo folder) che ha il client e connettersi al server dalla sh

Esempi di comandi

```sh
# Port-forsard al pod
kc port-forward -n quandopasso openssh-server  2222

# Connessione al server
psql -h db-deveu.postgres.database.azure.com -U psqladmin -d postgres

# Creazione del db quandopasso
createdb -h db-deveu.postgres.database.azure.com -U psqladmin quandopasso
```

## Tunnel SSH

Con questo pod si attiva un server SSH nel cluster

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ssh-to-db
  namespace: quandopasso
spec:
  containers:
    - name: test
      image: nowsci/sshtunnel
    volumes:
      - ./sshtunnel/data/:/data/:ro
    environment:
      - TUNNEL_HOST=172.17.0.4
      - TUNNEL_PORT=22
      - REMOTE_HOST=localhost
      - LOCAL_PORT=5432
      - REMOTE_PORT=5432
      - KEY=/data/keyfile
```

version: '2'

services:

  sshtunnel:
    image: nowsci/sshtunnel
    container_name: sshtunnel
    ports:
      - "2525:2525"
    volumes:
      - ./sshtunnel/data/:/data/:ro
    environment:
      - TUNNEL_HOST=host.example.com
      - TUNNEL_PORT=22
      - REMOTE_HOST=localhost
      - LOCAL_PORT=2525
      - REMOTE_PORT=25
      - KEY=/data/keyfile
    restart: always


