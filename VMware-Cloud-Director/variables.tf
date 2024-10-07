variable "vcd_url" {
  description = "The VMware Cloud Director URL"
  type        = string
}

variable "org" {
  description = "The organization in VCD"
  type        = string
}

variable "vdc" {
  description = "The virtual data center in VCD"
  type        = string
}

variable "user" {
  description = "The VCD username"
  type        = string
}

variable "password" {
  description = "The VCD password"
  type        = string
  sensitive   = true
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
}

variable "network_name" {
  description = "The network name to connect the VMs to"
}

variable "os_image_name" {
  description = "The OS image name available in the datastore"
}

variable "vm_memory" {
  description = "Memory size for each VM in MB"
  type        = number
}

variable "vm_cpus" {
  description = "Number of CPUs for each VM"
  type        = number
}

variable "disk_size" {
  description = "Size of the disk to attach in GB"
  type        = number
}

variable "sudo_user" {
  description = "The sudo user to create on the VM"
}

variable "sudo_password" {
  description = "The password for the sudo user"
}

variable "root_password" {
  description = "Root password for SSH connections"
}

variable "static_ips" {
  description = "static ips for SSH connections"
}

variable "app_name" {
  description = "vcd app name"
}

