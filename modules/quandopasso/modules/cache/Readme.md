# Cache module

## Multitenancy

This module is able to manage multitenancy by means of the instances list of configurations.

> Some elements are common to all instances (e.g. secrets) and should not be replicated per each tenant but in each namespece we have at leat one tenant: this is controlled byt the variable named ``namespaces``

With instances configuration it is possible to independently control singe instance ``namespace``, ``domain``, configuration and all related details. This implies that multiple different architecture are possible (e.g. different namespaces on same vhost/exchange, same namespace, ...) 