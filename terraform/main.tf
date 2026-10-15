terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.113.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    username    = ""
    private_key = file(pathexpand(""))
  }
}

# Download OPNsense ISO
resource "proxmox_download_file" "opnsense_iso" {
  content_type            = "iso"
  datastore_id            = var.iso_datastore
  node_name               = var.proxmox_node
  file_name               = "OPNsense-00.iso"
  url                     = ""
  decompression_algorithm = ""
  overwrite               = ""
  upload_timeout          = 
}

# Cloud-init snippet for single firewall
resource "proxmox_virtual_environment_file" "opnsense_user_data" {
  content_type = "snippets"
  datastore_id = var.iso_datastore
  node_name    = var.proxmox_node

  source_raw {
    data = <<-EOF
#cloud-config
hostname:
fqdn:
manage_etc_hosts: true
timezone: UTC

users:
  - name: admin
    groups: wheel
    shell: /bin/sh
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd:
    ssh_authorized_keys:
      - ${var.ssh_public_key}

ssh_pwauth:
disable_root:
EOF

    file_name = ""
  }
}

# Single OPNsense firewall VM
resource "proxmox_virtual_environment_vm" "opnsense" {
  name        = ""
  vm_id       = 
  node_name   = var.proxmox_node
  description = "OPNsense Firewall (Single Node)"
  tags        = ["opnsense", "firewall", "terraform"]

  boot_order = ["ide2", "scsi0"]

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.disk_datastore
    interface    = "scsi0"
    size         = 40
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_download_file.opnsense_iso.id
    interface = "ide2"
  }

  initialization {
    datastore_id = var.disk_datastore

    ip_config {
      ipv4 {
        address = ""
        gateway = ""
      }
    }

    dns {
      servers = [""]
    }

    user_data_file_id = proxmox_virtual_environment_file.opnsense_user_data.id
  }

  # LAN / Management interface only (NO WAN, NO pfSync)
  network_device {
    bridge   = var.lan_bridge
    model    = "virtio"
    firewall = false
    vlan_id  = 0
  }

  serial_device {}

  agent {
    enabled = false
  }

  bios    = "seabios"
  started = true

  lifecycle {
    ignore_changes = [initialization, cdrom, agent]
  }
}
