output "firewall_management_ip" {
  value       = ""
  description = "OPNsense management IP address"
}

output "firewall_gateway" {
  value       = ""
  description = "Default gateway for management network"
}

output "firewall_dns" {
  value       = ""
  description = "DNS server for management network"
}

output "vm_id" {
  value       = proxmox_virtual_environment_vm.opnsense.vm_id
  description = "Proxmox VM ID"
}
