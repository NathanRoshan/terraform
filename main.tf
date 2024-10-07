terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.14.0"
    }
  }
  required_version = ">= 1.0.0"
}


provider "vcd" {
  url                    = var.vcd_url
  org                    = var.org
  vdc                    = var.vdc
  user                   = var.user
  password               = var.password
  allow_unverified_ssl   = true
}

data "vcd_catalog" "my-catalog" {
  org  = var.org
  name = "csi"
}

data "vcd_catalog_vapp_template" "myMedia" {
  org     = var.org
  catalog_id = data.vcd_catalog.my-catalog.id
  name    = "Test-template"
}


# Create multiple VMs
resource "vcd_vapp" "multi_vm" {
  name  = var.app_name
  org   = var.org
  vdc   = var.vdc
}

resource "vcd_vapp_org_network" "routed-net" {
  vapp_name        = vcd_vapp.multi_vm.name
  org_network_name = "Test Network"
}


resource "vcd_vapp_vm" "multi_vm" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index + 1}"
  vapp_name           = vcd_vapp.multi_vm.name
  #catalog_id          = data.vcd_catalog.my_catalog.id
  vapp_template_id     = data.vcd_catalog_vapp_template.myMedia.id  # Use the ISO instead of a template
  memory              = var.vm_memory
  cpus                = var.vm_cpus
  cpu_cores        = 1
  power_on            = true
  # os_type          = "centos8_64Guest"
  # hardware_version = "vmx-14"
  computer_name    = "db-vm"

  network {
    type               = "org"
    name               = vcd_vapp_org_network.routed-net.org_network_name
    ip_allocation_mode = "MANUAL"
    ip                 = var.static_ips[count.index]
  } 
}


resource "vcd_vm_internal_disk" "disk2" {
  count           =  length(vcd_vapp_vm.multi_vm)
  vapp_name       =  vcd_vapp.multi_vm.name
  vm_name         =  vcd_vapp_vm.multi_vm[count.index].name
  bus_type        = "sata"
  size_in_mb      = "20480"
  bus_number      = 0
  unit_number     = 1
  storage_profile = "PowerStore SSD Policy"
  allow_vm_reboot = true
  depends_on      = [vcd_vapp_vm.multi_vm]
}


# SSH provisioner to set up LVM with XFS and create a sudo user
resource "null_resource" "provision_lvm_and_user" {
  count = var.vm_count

  connection {
    type     = "ssh"
    host     = vcd_vapp_vm.multi_vm[count.index].network[0].ip
    user     = "root"
    password = var.root_password
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "pvcreate /dev/sdb",
      "vgcreate vg_data /dev/sdb",
      "lvcreate -l 100%FREE -n lv_data vg_data",
      "mkfs.xfs /dev/vg_data/lv_data",
      "mkdir -p /storage",
      "mount /dev/vg_data/lv_data /storage",
      "echo '/dev/vg_data/lv_data /storage xfs defaults 0 0' >> /etc/fstab",
      # "useradd -m -s /bin/bash ${var.sudo_user}",
      # "echo '${var.sudo_user}:${var.sudo_password}' | chpasswd",
      # "usermod -aG sudo ${var.sudo_user}",
      # "echo '${var.sudo_user} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
    ]
  }
}
