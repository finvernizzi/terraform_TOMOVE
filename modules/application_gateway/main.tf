# https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/setup/install-existing.md

locals {
    backend_address_pool_name      = "${var.aks_net_name}-beap"
    frontend_port_name             = "${var.aks_net_name}-feport"
    # frontend_port_name_https       = "${var.aks_net_name}-https_feport"
    # This port will be configured by the cert manager with this name
    frontend_port_name_https       = "fp-443"
    frontend_ip_configuration_name = "${var.aks_net_name}-feip"
    http_setting_name              = "${var.aks_net_name}-be-htst"
    listener_name                  = "${var.aks_net_name}-httplstn"
    request_routing_rule_name      = "${var.aks_net_name}-rqrt"
    app_gateway_subnet_name        = var.appgw_subnet_name 
}

/**
* Needed for non Hashincorp providers
* [See](https://github.com/carlpett/terraform-provider-sops/issues/55#issuecomment-744594206)
*/
terraform {
  required_version = ">= 1.0"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

// TODO: verificare la apiVersion come indicato [qui](https://azure.github.io/aad-pod-identity/docs/#v16x-breaking-change)
// Per definizioni [Vedi](https://github.com/Azure/aad-pod-identity/blob/master/charts/aad-pod-identity/crds/crd.yaml)
resource "kubectl_manifest" "azureassignedidentities" {
    yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: unapproved
    controller-gen.kubebuilder.io/version: v0.5.0
  name: azureassignedidentities.aadpodidentity.k8s.io
  labels:
    app.kubernetes.io/name: aad-pod-identity
    app.kubernetes.io/instance: aad-pod-identity
    app.kubernetes.io/managed-by: Helm
    helm.sh/chart: aad-pod-identity
spec:
  group: aadpodidentity.k8s.io
  names:
    kind: AzureAssignedIdentity
    listKind: AzureAssignedIdentityList
    plural: azureassignedidentities
    singular: azureassignedidentity
  scope: Namespaced
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: AzureAssignedIdentity contains the identity <-> pod mapping which is matched.
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: AzureAssignedIdentitySpec contains the relationship between an AzureIdentity and an AzureIdentityBinding.
            properties:
              azureBindingRef:
                description: AzureBindingRef is an embedded resource referencing the AzureIdentityBinding used by the AzureAssignedIdentity, which requires x-kubernetes-embedded-resource fields to be true
                properties:
                  apiVersion:
                    description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
                    type: string
                  kind:
                    description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
                    type: string
                  metadata:
                    type: object
                  spec:
                    description: AzureIdentityBindingSpec matches the pod with the Identity. Used to indicate the potential matches to look for between the pod/deployment and the identities present.
                    properties:
                      azureIdentity:
                        type: string
                      metadata:
                        type: object
                      selector:
                        type: string
                      weight:
                        description: Weight is used to figure out which of the matching identities would be selected.
                        type: integer
                    type: object
                  status:
                    description: AzureIdentityBindingStatus contains the status of an AzureIdentityBinding.
                    properties:
                      availableReplicas:
                        format: int32
                        type: integer
                      metadata:
                        type: object
                    type: object
                type: object
                x-kubernetes-embedded-resource: true
              azureIdentityRef:
                description: AzureIdentityRef is an embedded resource referencing the AzureIdentity used by the AzureAssignedIdentity, which requires x-kubernetes-embedded-resource fields to be true
                properties:
                  apiVersion:
                    description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
                    type: string
                  kind:
                    description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
                    type: string
                  metadata:
                    type: object
                  spec:
                    description: AzureIdentitySpec describes the credential specifications of an identity on Azure.
                    properties:
                      adEndpoint:
                        type: string
                      adResourceID:
                        description: For service principal. Option param for specifying the  AD details.
                        type: string
                      auxiliaryTenantIDs:
                        description: Service principal auxiliary tenant ids
                        items:
                          type: string
                        nullable: true
                        type: array
                      clientID:
                        description: Both User Assigned MSI and SP can use this field.
                        type: string
                      clientPassword:
                        description: Used for service principal
                        properties:
                          name:
                            description: Name is unique within a namespace to reference a secret resource.
                            type: string
                          namespace:
                            description: Namespace defines the space within which the secret name must be unique.
                            type: string
                        type: object
                      metadata:
                        type: object
                      replicas:
                        format: int32
                        nullable: true
                        type: integer
                      resourceID:
                        description: User assigned MSI resource id.
                        type: string
                      tenantID:
                        description: Service principal primary tenant id.
                        type: string
                      type:
                        description: UserAssignedMSI or Service Principal
                        type: integer
                    type: object
                  status:
                    description: AzureIdentityStatus contains the replica status of the resource.
                    properties:
                      availableReplicas:
                        format: int32
                        type: integer
                      metadata:
                        type: object
                    type: object
                type: object
                x-kubernetes-embedded-resource: true
              metadata:
                type: object
              nodename:
                type: string
              pod:
                type: string
              podNamespace:
                type: string
              replicas:
                format: int32
                nullable: true
                type: integer
            type: object
          status:
            description: AzureAssignedIdentityStatus contains the replica status of the resource.
            properties:
              availableReplicas:
                format: int32
                type: integer
              metadata:
                type: object
              status:
                type: string
            type: object
        type: object
    served: true
    storage: true
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
YAML
}
resource "kubectl_manifest" "azureidentities" {
    yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: unapproved
    controller-gen.kubebuilder.io/version: v0.5.0
  name: azureidentities.aadpodidentity.k8s.io
  labels:
    app.kubernetes.io/name: aad-pod-identity
    app.kubernetes.io/instance: aad-pod-identity
    app.kubernetes.io/managed-by: Helm
    helm.sh/chart: aad-pod-identity
spec:
  group: aadpodidentity.k8s.io
  names:
    kind: AzureIdentity
    listKind: AzureIdentityList
    plural: azureidentities
    singular: azureidentity
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - jsonPath: .spec.type
      name: Type
      type: string
    - jsonPath: .spec.clientID
      name: ClientID
      type: string
    - description: CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.
      jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    name: v1
    schema:
      openAPIV3Schema:
        description: AzureIdentity is the specification of the identity data structure.
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: AzureIdentitySpec describes the credential specifications of an identity on Azure.
            properties:
              adEndpoint:
                type: string
              adResourceID:
                description: For service principal. Option param for specifying the  AD details.
                type: string
              auxiliaryTenantIDs:
                description: Service principal auxiliary tenant ids
                items:
                  type: string
                nullable: true
                type: array
              clientID:
                description: Both User Assigned MSI and SP can use this field.
                type: string
              clientPassword:
                description: Used for service principal
                properties:
                  name:
                    description: Name is unique within a namespace to reference a secret resource.
                    type: string
                  namespace:
                    description: Namespace defines the space within which the secret name must be unique.
                    type: string
                type: object
              metadata:
                type: object
              replicas:
                format: int32
                nullable: true
                type: integer
              resourceID:
                description: User assigned MSI resource id.
                type: string
              tenantID:
                description: Service principal primary tenant id.
                type: string
              type:
                description: UserAssignedMSI or Service Principal
                type: integer
            type: object
          status:
            description: AzureIdentityStatus contains the replica status of the resource.
            properties:
              availableReplicas:
                format: int32
                type: integer
              metadata:
                type: object
            type: object
        type: object
    served: true
    storage: true
    subresources: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
YAML
}
resource "kubectl_manifest" "azureidentitybindings" {
    yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: unapproved
    controller-gen.kubebuilder.io/version: v0.5.0
  name: azureidentitybindings.aadpodidentity.k8s.io
  labels:
    app.kubernetes.io/name: aad-pod-identity
    app.kubernetes.io/instance: aad-pod-identity
    app.kubernetes.io/managed-by: Helm
    helm.sh/chart: aad-pod-identity
spec:
  group: aadpodidentity.k8s.io
  names:
    kind: AzureIdentityBinding
    listKind: AzureIdentityBindingList
    plural: azureidentitybindings
    singular: azureidentitybinding
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - jsonPath: .spec.azureIdentity
      name: AzureIdentity
      type: string
    - jsonPath: .spec.selector
      name: Selector
      type: string
    - description: CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.
      jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    name: v1
    schema:
      openAPIV3Schema:
        description: AzureIdentityBinding brings together the spec of matching pods and the identity which they can use.
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: AzureIdentityBindingSpec matches the pod with the Identity. Used to indicate the potential matches to look for between the pod/deployment and the identities present.
            properties:
              azureIdentity:
                type: string
              metadata:
                type: object
              selector:
                type: string
              weight:
                description: Weight is used to figure out which of the matching identities would be selected.
                type: integer
            type: object
          status:
            description: AzureIdentityBindingStatus contains the status of an AzureIdentityBinding.
            properties:
              availableReplicas:
                format: int32
                type: integer
              metadata:
                type: object
            type: object
        type: object
    served: true
    storage: true
    subresources: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
YAML
}
resource "kubectl_manifest" "azurepodidentityexceptions" {
    yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: unapproved
    controller-gen.kubebuilder.io/version: v0.5.0
  name: azurepodidentityexceptions.aadpodidentity.k8s.io
  labels:
    app.kubernetes.io/name: aad-pod-identity
    app.kubernetes.io/instance: aad-pod-identity
    app.kubernetes.io/managed-by: Helm
    helm.sh/chart: aad-pod-identity
spec:
  group: aadpodidentity.k8s.io
  names:
    kind: AzurePodIdentityException
    listKind: AzurePodIdentityExceptionList
    plural: azurepodidentityexceptions
    singular: azurepodidentityexception
  scope: Namespaced
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: AzurePodIdentityException contains the pod selectors for all pods that don't require NMI to process and request token on their behalf.
        properties:
          apiVersion:
            description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
            type: string
          kind:
            description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
            type: string
          metadata:
            type: object
          spec:
            description: AzurePodIdentityExceptionSpec matches pods with the selector defined. If request originates from a pod that matches the selector, nmi will proxy the request and send response back without any validation.
            properties:
              metadata:
                type: object
              podLabels:
                additionalProperties:
                  type: string
                type: object
            type: object
          status:
            description: AzurePodIdentityExceptionStatus contains the status of an AzurePodIdentityException.
            properties:
              metadata:
                type: object
              status:
                type: string
            type: object
        type: object
    served: true
    storage: true
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
YAML
}
resource "kubectl_manifest" "mic" {
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    component: mic
  name: mic
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      component: mic
  template:
    metadata:
      labels:
        component: mic
    spec:
      containers:
      - name: mic
        image: "mcr.microsoft.com/k8s/aad-pod-identity/mic:1.6.0"
        imagePullPolicy: Always
        args:
          - "--kubeconfig=/etc/kubernetes/kubeconfig/kubeconfig"
          - "--cloudconfig=/etc/kubernetes/azure.json"
          - "--logtostderr"
        env:
        - name: MIC_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace       
        resources:
          limits:
            cpu: 200m
            memory: 1024Mi
          requests:
            cpu: 100m
            memory: 256Mi
        volumeMounts:
          - name: kubeconfig
            mountPath: /etc/kubernetes/kubeconfig
            readOnly: true
          - name: certificates
            mountPath: /etc/kubernetes/certs
            readOnly: true
          - name: k8s-azure-file
            mountPath: /etc/kubernetes/azure.json
            readOnly: true
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: kubeconfig
        hostPath:
          path: /var/lib/kubelet
      - name: certificates
        hostPath:
          path: /etc/kubernetes/certs
      - name: k8s-azure-file
        hostPath:
          path: /etc/kubernetes/azure.json
      nodeSelector:
        beta.kubernetes.io/os: linux
YAML
}
resource "kubectl_manifest" "nmi" {
    yaml_body = <<YAML
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    component: nmi
    tier: node
  name: nmi
  namespace: default
spec:
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      component: nmi
      tier: node
  template:
    metadata:
      labels:
        component: nmi
        tier: node
    spec:
      hostNetwork: true
      volumes:
      - hostPath:
          path: /run/xtables.lock
          type: FileOrCreate
        name: iptableslock
      containers:
      - name: nmi
        image: "mcr.microsoft.com/k8s/aad-pod-identity/nmi:1.6.0"
        imagePullPolicy: Always
        args:
          - "--host-ip=$(HOST_IP)"
          - "--node=$(NODE_NAME)"
        env:
          - name: HOST_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
        securityContext:
          privileged: true
          capabilities:
            add:
            - NET_ADMIN
        resources:
          limits:
            cpu: 200m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 256Mi
        volumeMounts:
        - mountPath: /run/xtables.lock
          name: iptableslock
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
      nodeSelector:
        beta.kubernetes.io/os: linux
YAML
}

# User Assigned Identities 
# Crea questa nuova identity su AAD per dargli i permessi di accesso al resource group ed al Application Gateway
# Attenzione anche ai pod del MSI (Managed Service Identity). Di solito il nome inizia con mic
# deve avere: 
# - Reader su resourceGroup
# - Contributor su AAG
resource "azurerm_user_assigned_identity" "aagIdentity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.identity_name
  tags                = var.tags
}

# Give AGIC's identity Reader access to the App Gateway resource group.
# OSS: il principal ID è il chi, scope è il `su cosa`
resource "azurerm_role_assignment" "agic_reader_role" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aagIdentity.principal_id
}


# Azure Application Gateway
resource "azurerm_application_gateway" "application_gateway" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name              = var.app_gateway_sku
    tier              = var.app_gateway_tier
    capacity          = var.application_gateway_capacity
  }

  gateway_ip_configuration {
    name              = "appGatewayIpConfig"
    subnet_id         = var.appgwsubnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
  tags    = var.tags
  lifecycle {
    ignore_changes = [
      #
      # AAG configuration is done by means of Ingress Controller. 
      # We ignore changes dynamically done by it.
      # This prevents AAG config being removed by terraform refresh
      #
      # [See](https://itnext.io/how-and-when-to-ignore-lifecycle-changes-in-terraform-ed5bfb46e7ae)
      backend_http_settings,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      redirect_configuration,
      request_routing_rule,
      ssl_certificate,
      url_path_map,
      tags,
      frontend_port
    ]
  }
}

# Give AGIC's identity Contributor access to you App Gateway.
resource "azurerm_role_assignment" "agic_contributor_role" {
  scope                = azurerm_application_gateway.application_gateway.id
  role_definition_name = "Contributor"
  principal_id         = var.aks_service_principal_object_id 
}

resource "azurerm_role_assignment" "ra1" {
  scope                = var.kubesubnet_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aks_service_principal_object_id 
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.aagIdentity.id
  # role_definition_name = "Managed Identity Operator"
  role_definition_name = "Contributor"
  principal_id         = var.aks_service_principal_object_id
  depends_on           = [azurerm_user_assigned_identity.aagIdentity]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.application_gateway.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aagIdentity.principal_id
  depends_on           = [azurerm_user_assigned_identity.aagIdentity]
}
resource "azurerm_role_assignment" "ra4" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aagIdentity.principal_id
  depends_on           = [azurerm_user_assigned_identity.aagIdentity, azurerm_application_gateway.application_gateway]
}

/**
* Ingress Controller
* [See](https://azure.microsoft.com/en-us/blog/application-gateway-ingress-controller-for-azure-kubernetes-service/)
**/
resource "helm_release" "ingress_controller" {
  name              = "aag-ingress-controller"

  repository        = var.aag_ingress_controller_helm.repository
  chart             = var.aag_ingress_controller_helm.chart
  version           = var.aag_ingress_controller_helm.version
  create_namespace  = true
  namespace         = var.namespace

  cleanup_on_fail   = true
  
  values               = [ 
    templatefile(
      "${path.module}/ingress_controller.template.yml", 
      {
        resource-group-name: var.resource_group_name
        identityClientID: azurerm_user_assigned_identity.aagIdentity.client_id
        identityName: azurerm_user_assigned_identity.aagIdentity.name
        subscription_id: var.subscription_id
        applicationa_gateway_name: azurerm_application_gateway.application_gateway.name
      }
  )]
}