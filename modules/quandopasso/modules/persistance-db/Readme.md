# Persistence module

This module is responsible of persistence of volatile data in the quandopasso architecture.
It installs only the database itself as a statefullset and no any specific service for managing data in the database.
It is composed of a ``statefull set`` for the Pstgresql database server.

> Keep user/pass updated also in ``exporter_data_source``in vault to have postgresql openmetrics updated 

## Backup

For a dump (complete or only data) [see](https://www.postgresql.org/docs/9.1/backup-dump.html#BACKUP-DUMP-ALL).

> Example: ``pg_dumpall -f ./test_eu_db_16082021 -h 127.0.0.1 -p 5433 -U localuser``
