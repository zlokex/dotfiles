locals {
  vm_ipv4_addresses = [
    for addr in libvirt_domain.vm.network_interface[0].addresses :
    addr if can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", addr))
  ]
  vm_ipv4 = try(local.vm_ipv4_addresses[0], null)
}

output "vm_ip" {
  description = "IPv4 address reported by the libvirt DHCP lease / guest agent."
  value       = local.vm_ipv4
}

output "ssh_command" {
  description = "Ready-to-paste SSH command for the fedora user."
  value       = "ssh fedora@${coalesce(local.vm_ipv4, "<pending>")}"
}

output "console_hint" {
  description = "Open a SPICE console for the guest."
  value       = "virt-viewer --connect ${var.libvirt_uri} ${var.vm_name}"
}
