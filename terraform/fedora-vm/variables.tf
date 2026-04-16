variable "vm_name" {
  description = "Libvirt domain name, guest hostname, and disk filename prefix."
  type        = string
  default     = "fedora43-ws"
}

variable "vcpus" {
  description = "Number of vCPUs for the guest."
  type        = number
  default     = 4
}

variable "memory_mib" {
  description = "Guest RAM in MiB."
  type        = number
  default     = 8192
}

variable "disk_gib" {
  description = "Guest root disk size in GiB. Grown from the base image by cloud-init on first boot."
  type        = number
  default     = 80
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key injected into the fedora user via cloud-init."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "user_password_hash" {
  description = <<-EOT
    SHA-512 crypt hash for the fedora user (used for GDM / console login).
    Generate with: openssl passwd -6
  EOT
  type        = string
  sensitive   = true
}

variable "fedora_image_url" {
  description = "URL of the Fedora 43 Cloud Base qcow2. Pin to an exact respin."
  type        = string
  default     = "https://download.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
}

variable "vm_mac" {
  description = <<-EOT
    MAC address pinned on the guest NIC. A stable MAC yields a stable DHCP lease
    from libvirt's dnsmasq, so the VM keeps the same NAT IP across rebuilds.
    Must be in the QEMU OUI (52:54:00:xx:xx:xx).
  EOT
  type        = string
  default     = "52:54:00:fe:da:43"
}

variable "libvirt_uri" {
  description = "Libvirt connection URI. Use qemu:///system so it matches virt-manager's default view."
  type        = string
  default     = "qemu:///system"
}

variable "network_name" {
  description = "Libvirt network to attach the guest NIC to."
  type        = string
  default     = "default"
}

variable "pool_name" {
  description = "Libvirt storage pool for the base image, VM disk, and cloud-init ISO."
  type        = string
  default     = "default"
}
