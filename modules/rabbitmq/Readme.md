# RabbitMQ

RabbitMQ is the message broker for communications between al microservices.

## User and password

> The generation of the rabbit config file is done using a ``for`` loop expression from HCL. See [here](https://www.terraform.io/docs/language/expressions/for.html) for documentation.

**ADMIN** User and password are randomly generated dunring installation. Values are saved into a local file names ``.rabbitmq``.
Password for services (e.g. cache, cb-api, ...) are read from local vault and stored in the rabbitmq-users secret.

> Users will have same privileges on each defined vhosts, whith the exception of admin.

## PLugins

The rabbitmq instance has the ``rabbitmq_prometheus`` plugin enabled.

## cyrilgdn/rabbitmq/ provider

We DO NOT use this provider since it requires to abilitate the management:_plugin and to access rabbitmq with a port-forward


## Reload definitions

If some configuration is changed, connect to the rabbit instance and

```sh
rabbitmqctl shitdown
```

> Not sure this is the best way. The hosts goes down and after a while restarts. The POD is always up, but all NODES CONNECTED LOSE THE CONNECTION!