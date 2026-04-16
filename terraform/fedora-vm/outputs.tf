output "vm_ip" {
  description = "IPv4 address reported by the libvirt DHCP lease / guest agent."
  value       = try(libvirt_domain.vm.network_interface[0].addresses[0], null)
}

output "ssh_command" {
  description = "Ready-to-paste SSH command for the fedora user."
  value       = "ssh fedora@${try(libvirt_domain.vm.network_interface[0].addresses[0], "<pending>")}"
}

output "console_hint" {
  description = "Open a SPICE console for the guest."
  value       = "virt-viewer --connect ${var.libvirt_uri} ${var.vm_name}"
}
