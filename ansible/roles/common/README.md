# Ansible Role: Common

## Objective
Provides basic configuration and tools for use across all environments and roles.

## Role Dependencies
None

## Summary

- Sets hostname (via variable), timezone (to `UTC`) and locale (to `en_GB`)
- Updates Apt cache
- Ensures common packages are installed
