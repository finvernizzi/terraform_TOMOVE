# Persistence module

This module is responsible of persistence of volatile dat in the quandopasso architecture.

The DB part is available for other modules (e.g. terminals.counter) to store information in a persistent way

> Keep user/pass updated also in ``exporter_data_source``in vault to have postgresql openmetrics updated 

## Multitenancy

The module instantiate a different helm chart for each tenant, with all details configurable.

## Backup

For a dump (complete or only data) [see](https://www.postgresql.org/docs/9.1/backup-dump.html#BACKUP-DUMP-ALL).

> Example: ``pg_dumpall -f ./test_eu_db_16082021 -h 127.0.0.1 -p 5433 -U localuser``
>


## Env var 

[See](https://www.postgresql.org/docs/current/libpq-envars.html#id-1.7.3.21.3.4.12.1.1)

## Accessing the DB

The database is an azure managed instance. To access it, run the openssh-server and access with a tunnel

```sh
# create the pod 
kc apply -n quandopasso -f openssh-server.yaml
# port-forward to pod
kc port-forward -n quandopasso openssh-server  2222
# Create a SSH tunnel
ssh -L127.0.0.1:5432:172.17.0.4:5432 quandopasso@127.0.0.1 -p 2222
```

> User and pass for the SSH server are confgiurable in the pod yaml