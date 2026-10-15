## OPNsense HA on Proxmox — Ansible Automation
Infrastructure-as-Code (IaC) automation for deploying and configuring a highly available OPNsense firewall pair running on Proxmox VE, using Ansible and the oxlorg.opnsense collection


## Overview
This repository provides a fully declarative, idempotent Ansible playbook suite that configures two OPNsense instances (opnsense01 as master, opnsense02 as backup) in a CARP/pfsync high-availability setup on Proxmox.

It covers:

DHCP server and static reservations

DNS (Unbound) with DoT forwarding

Firewall rules and aliases

NAT (source & destination)

Security zones (interface groups)

IDS/IPS (Suricata with ET Open / abuse.ch rulesets)

Users & groups

WireGuard VPN


## Prerequisites
On the control node
Ansible 2.15+

Python 3.10+

Required collection:
ansible-galaxy collection install oxlorg.opnsense

Python dependencies for the collection:
pip install ansible-collection-opnsense

## On the OPNsense firewalls
OPNsense 24.x+

API access enabled (System → Settings → Administration)

An API key/secret pair generated for an admin user

The API key file stored locally (path referenced via OPNSENSE_API_KEY_FILE)

Firewall reachable over HTTPS from the control node

# Environment variables
export OPNSENSE_API_KEY_FILE="/path/to/opnsense_api_credentials"
Content: key=your-api-key
         secret=your-api-secret

⚠️ Never commit real credentials to this repository. The inventory file contains placeholders only.


## Inventory
Edit inventory/hosts.yml and set the real management IPs.
For a Proxmox HA setup, these IPs typically correspond to the CARP VIP or the individual node management addresses.

## Usage
- Run the full playbook:
  ansible-playbook -i inventory/hosts.yml site.yml

- Run a single component, e.g. only DNS:
  ansible-playbook -i inventory/hosts.yml dns.yml

- Dry-run to preview changes:
  ansible-playbook -i inventory/hosts.yml site.yml --check --diff

- Limit to one node:
  ansible-playbook -i inventory/hosts.yml site.yml --limit opnsense01

## Playbook Details
Playbook	              Purpose
firewall_rules.yml	      Creates aliases (TRUST_NET, DMZ_NET, etc.) and generic firewall rules on WAN/DMZ/GUEST/LAN
dhcp.yml	              Configures DHCP ranges (master only) and static reservations on the DMZ interface
dns.yml	                      Enables Unbound with DNSSEC, adds host overrides and DoT forwarders
nat.yml	                      Outbound SNAT for LAN, inbound port-forwards for web and SSH
security_zones.yml	      Creates interface groups and enforces zone-to-zone policy
ids_ips.yml	              Downloads ET Open / abuse.ch rulesets and applies a drop policy (master only)
users_groups.yml	      Creates admins, operators, auditors groups and user accounts
vpn_wireguard.yml	      Sets up WireGuard server and site-to-site peer (master only)

## Secrets Management
This repo assumes secrets are injected at runtime:

- API credentials via OPNSENSE_API_KEY_FILE
- WireGuard private keys and user passwords via Ansible Vault

- Encrypt sensitive files:
  ansible-vault encrypt inventory/group_vars/opnsense/vault.yml

- Run with:
  ansible-playbook -i inventory/hosts.yml site.yml --ask-vault-pass


## Disclaimer
## This project is not affiliated with or endorsed by the OPNsense project or Proxmox. Use at your own risk, especially when applying firewall rules to a production edge device. Always test in a lab first.
