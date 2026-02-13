terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.1.225:8006/api2/json"
  pm_api_token_id     = "root@pam!packer"
  pm_api_token_secret = "48bb64b3-1554-463a-841a-e3067a91ff1d"
  pm_tls_insecure     = true
}

data "template_file" "nomad_config_script" {
  template = file("${path.module}/configure_nomad.sh.tpl")
}

# Create 3 server nodes (will run both Nomad server and Consul server)
resource "proxmox_vm_qemu" "nomad_server" {
  count       = 3
  name        = "nomad-server-${count.index + 1}"
  target_node = var.proxmox_host
  clone       = var.template_name
  full_clone  = true

  # Basic VM settings
  agent    = 1
  os_type  = "cloud-init"
  cores    = 2
  sockets  = 1
  cpu_type = "host"
  memory   = 2048  # More memory for servers
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  # Main Disk Configuration
  disk {
    slot     = "scsi0"
    size     = "10G"
    type     = "disk"
    storage  = "local-lvm"
    iothread = true
  }

  # Cloud-Init Disk Configuration
  disk {
    slot     = "scsi1"
    type     = "cloudinit"
    storage  = "local-lvm"
    iothread = false
  }

  # Network Configuration - VLAN20
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag    = 20
  }

  # IP configuration via cloud-init (10.0.0.10-12)
  ipconfig0 = "ip=10.0.0.1${count.index}/8,gw=10.0.0.1"

  # SSH Key Injection
  sshkeys = var.ssh_key

  # Cloud-Init Custom User Data
  cicustom = "user=local:snippets/user-data-server.yaml"

  # Connection for provisioners
  connection {
    type        = "ssh"
    user        = "laurelio"
    private_key = file("~/.ssh/id_rsa")
    host        = "10.0.0.1${count.index}"
    timeout     = "10m"
    agent	= false
  }

  # Provision Nomad configuration
  #provisioner "file" {
  #  content     = data.template_file.nomad_config_script.rendered
  #  destination = "/tmp/configure_nomad.sh"
  #  #on_failure  = "continue"
  #}

  #provisioner "remote-exec" {
  #  inline = [
  #    "chmod +x /tmp/configure_nomad.sh",
  #    "/tmp/configure_nomad.sh || echo 'Configuration script failed'"
  #  ]
  #}

  lifecycle {
    ignore_changes = [network]
  }
}

# Create 3 client nodes (will run Nomad client and Consul client)
resource "proxmox_vm_qemu" "nomad_client" {
  count       = 3
  name        = "nomad-client-${count.index + 1}"
  target_node = var.proxmox_host
  clone       = var.template_name
  full_clone  = true

  # Basic VM settings
  agent    = 1
  os_type  = "cloud-init"
  cores    = 4  # More cores for clients
  sockets  = 1
  cpu_type = "host"
  memory   = 4096  # More memory for clients
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  # Main Disk Configuration
  disk {
    slot     = "scsi0"
    size     = "20G"
    type     = "disk"
    storage  = "local-lvm"
    iothread = true
  }

  # Cloud-Init Disk Configuration
  disk {
    slot     = "scsi1"
    type     = "cloudinit"
    storage  = "local-lvm"
    iothread = false
  }

  # Network Configuration - VLAN20
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag    = 20
  }

  # IP configuration via cloud-init (10.0.0.13-15)
  ipconfig0 = "ip=10.0.0.1${count.index + 3}/8,gw=10.0.0.1"

  # SSH Key Injection
  sshkeys = var.ssh_key

  # Cloud-Init Custom User Data
  cicustom = "user=local:snippets/user-data-client.yaml"

  # Connection for provisioners
  connection {
    type        = "ssh"
    user        = "laurelio"
    private_key = file("~/.ssh/id_rsa")
    host        = "10.0.0.1${count.index + 3}"
    timeout     = "10m"
    agent	= false
  }

  # Provision Nomad configuration
  #provisioner "file" {
  #  content     = data.template_file.nomad_config_script.rendered
  #  destination = "/tmp/configure_nomad.sh"
  #}

  #provisioner "remote-exec" {
  #  inline = [
  #    "chmod +x /tmp/configure_nomad.sh",
  #    "/tmp/configure_nomad.sh"
  #  ]
  #}

  lifecycle {
    ignore_changes = [network]
  }
}
