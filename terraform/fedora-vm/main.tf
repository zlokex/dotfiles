resource "libvirt_volume" "fedora_base" {
  name   = "fedora43-cloud-base.qcow2"
  pool   = var.pool_name
  source = var.fedora_image_url
  format = "qcow2"
}

resource "libvirt_volume" "vm_disk" {
  name           = "${var.vm_name}.qcow2"
  pool           = var.pool_name
  base_volume_id = libvirt_volume.fedora_base.id
  size           = var.disk_gib * 1024 * 1024 * 1024
  format         = "qcow2"
}

resource "tls_private_key" "host_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "host_ed25519" {
  algorithm = "ED25519"
}

resource "libvirt_cloudinit_disk" "ci" {
  name = "${var.vm_name}-cloudinit.iso"
  pool = var.pool_name

  user_data = templatefile("${path.module}/templates/user-data.yaml.tftpl", {
    hostname           = var.vm_name
    ssh_public_key     = trimspace(file(pathexpand(var.ssh_public_key_path)))
    user_password_hash = var.user_password_hash
    host_rsa_private     = chomp(tls_private_key.host_rsa.private_key_openssh)
    host_rsa_public      = chomp(tls_private_key.host_rsa.public_key_openssh)
    host_ed25519_private = chomp(tls_private_key.host_ed25519.private_key_openssh)
    host_ed25519_public  = chomp(tls_private_key.host_ed25519.public_key_openssh)
  })

  meta_data = templatefile("${path.module}/templates/meta-data.yaml.tftpl", {
    hostname = var.vm_name
  })

  network_config = templatefile("${path.module}/templates/network-config.yaml.tftpl", {})
}

resource "libvirt_domain" "vm" {
  name      = var.vm_name
  memory    = var.memory_mib
  vcpu      = var.vcpus
  autostart = false

  cloudinit  = libvirt_cloudinit_disk.ci.id
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_name   = var.network_name
    mac            = var.vm_mac
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  video {
    type = "qxl"
  }
}
