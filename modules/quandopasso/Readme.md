# Introduction

This modules installs all Quandopasso required elements for a complete installation.
It requires a valid k8s cluster installed.

All software is installe by means of *helm charts*.

Each application is defined in a dedicated module

## PullImage auth

Credentials are stored by the root quandopasso module in _azcr_pullimage_secret_name_ and all sub-module are expected to use this secret to authenticate in image pull operations. In this way we can have a centralized secret in use to all application.

## AVS categories

We use a configmap for each domain named ``mobile-categories-<DOMAIN>``. The configmap is managed by the mobile-api module, **directly in the HELM chart** via the categories.json file (in the vault). In order to have the service see a change in the configmap requires a reload of the services.