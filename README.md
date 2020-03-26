# Simon's Platform Library

This repository contains various infrastructure-as-code elements,
primarily geared around setting up development environments.

Terraform is used for the provisioning of infrastructure.
Ansible is used for the configuration of provisioned infrastructure.

Platform and OS agnostic approaches are taken where possible but the primary target OS is Ubuntu
and the primary target platform is AWS.

## Ansible

As this repository is not specifically targeting production environments it generally eschews roles in favour of
simple task files. The exceptions being cases where a role structure is preferable due to configuration files, handlers,
etc being useful/required.

The simple task files would form the basis of a role structure in a production repository
