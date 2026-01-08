## TLS 

This module configures certificate management by means of [letsencrypt](https://letsencrypt.org/) certificate authority, with cert-bot authomatic challenge management.

We install specific ``CRDs`` to operate all the needed elements. We install needed CRDs [by means of](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs) plugin.


## Version and documentation

[Doc](https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/how-tos/lets-encrypt.md)

## Troubleshoot

[DOC](https://cert-manager.io/docs/faq/acme/)
[DOC](https://cert-manager.io/docs/installation/helm/)

## Staging vs prod

We have configured 2 cert-manager: ``prod`` and ``staging`` in order to test without problems with [letsencrypt rate limiting](https://letsencrypt.org/docs/rate-limits/)

In order to use one of the 2 defined cert-manager, use the following annotations in any ingress rules.

```yaml
# Prod (ingress)
annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod

# Staging (ingress
annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
```
## Troubeshooting

Usefull comands and documentation [here](https://cert-manager.io/docs/faq/acme/)

## Monitoring

[See](https://grafana.com/grafana/dashboards/13922-certificates-expiration-x509-certificate-exporter/)