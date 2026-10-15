variable "proxmox_endpoint" {
  description = "Enter the API URL of your PVE" 
  type    = string
  default = ""
}

variable "ssh_public_key" {
  description = "SSH public key for admin access to OPNsense VM"
  type        = string
  default     = ""
}

variable "proxmox_api_token" {
  description = "The API key created on the PVE console or GUI"
  type      = string
  sensitive = true
  default   = ""
}

variable "proxmox_node" {
  description = "The hostname of the target PVE host"
  type    = string
  default = ""
}

variable "iso_datastore" {
  description = "The name of the PVE datastore that supports storing .iso files"
  type    = string
  default = ""
}

variable "disk_datastore" {
  description = "The name of the PVE datastore that supports storing disk files"
  type    = string
  default = ""
}

variable "lan_bridge" {
  description = "Bridge for LAN/Management interface"
  type        = string
  default     = ""
}
