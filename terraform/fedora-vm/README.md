# fedora-vm

Terraform stack that provisions a local **Fedora Workstation 43** VM on
KVM/libvirt, managed alongside virt-manager.

The VM boots from the upstream Fedora 43 Cloud Base qcow2 and uses cloud-init
to install `@workstation-product-environment`, enable GDM, inject your SSH
key, and reboot into a graphical GNOME session.

## Prerequisites

Most of these are already installed/enabled by this repo's Ansible play
(`site.yml`):

- `libvirt-daemon-kvm`, `qemu-kvm`, `qemu-guest-agent`, `virt-install`,
  `virt-manager`, `virt-viewer` — from `ansible/fedora-workstation/roles/dnf_packages`
  (`dnf_packages_virt`).
- `libvirtd` enabled, user in `libvirt` + `kvm` groups — from
  `ansible/fedora-workstation/roles/services`. Re-login after the first bootstrap so
  the group membership is active (check with `id`).
- `terraform` — added to `dnf_packages_dev` by this change. On a host that
  predates that change: `sudo dnf install -y terraform`.
- `openssl` (for the password hash) — installed by default on Fedora.

## Usage

```sh
cd terraform/fedora-vm

# 1. Generate a SHA-512 password hash for the `fedora` user.
openssl passwd -6

# 2. Create your tfvars.
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars   # paste the hash; tweak sizes / ssh key path if needed

# 3. Apply.
terraform init
terraform plan
terraform apply
```

First apply takes 5–15 min: base image download (~500 MB), cloud-init
`dnf group install workstation-product-environment` (~1–2 GB), then a reboot
into GDM.

## Reaching the VM

```sh
# IP from the guest agent (works as soon as qemu-guest-agent is up):
virsh -c qemu:///system domifaddr fedora43-ws --source agent

# Or let Terraform tell you:
terraform output ssh_command

# SSH (SSH key was injected by cloud-init):
ssh fedora@<ip>

# Graphical console:
virt-manager &     # pick fedora43-ws, double-click
# or:
virt-viewer --connect qemu:///system fedora43-ws
```

## Destroying

```sh
terraform destroy
```

Removes the domain, the per-VM disk, and the cloud-init ISO. The cached base
image volume is also destroyed and will be re-downloaded on the next apply.

## Notes

- Connection is `qemu:///system`, matching virt-manager's default view — no
  `sudo` needed as long as you're in the `libvirt` group.
- The `default` NAT network and `default` storage pool
  (`/var/lib/libvirt/images`) are used. SELinux labels are correct out of the
  box there; don't move to a custom path without re-labeling.
- `fedora_image_url` is pinned to an exact respin (`-43-1.6`). Bump it
  deliberately when Fedora ships a new one — don't point at "latest" or the
  base volume gets invalidated on every apply.
- If `terraform apply` hangs on `wait_for_lease`, the default libvirt network
  likely isn't up:
  `sudo virsh net-start default && sudo virsh net-autostart default`.
- To re-run cloud-init (e.g. after editing user-data), `terraform taint
libvirt_cloudinit_disk.ci` and re-apply — or destroy/apply the whole stack.

## Stable identity across rebuilds

The guest NIC is pinned to `var.vm_mac` (default `52:54:00:fe:da:43`), so
libvirt's dnsmasq hands out the same NAT IP every rebuild.

**Why we pre-generate the VM's SSH host keys**: by default sshd generates
fresh host keys on first boot, so every rebuild changes the VM's fingerprint
and you'd hit `HOST IDENTIFICATION HAS CHANGED`. Instead, Terraform generates
RSA + ED25519 keypairs once (`tls_private_key`) and cloud-init writes them to
`/etc/ssh/ssh_host_*` on each boot — same IP, same fingerprint, stable
`~/.ssh/known_hosts`.

**Security note**: the VM's SSH host private keys live in `terraform.tfstate`
(sensitive). State is local and `.gitignored`, so this is fine for a personal
dev VM — but don't commit or copy state.

**Rotate the VM's identity** (e.g. after you've handed it off):

```sh
terraform taint tls_private_key.host_rsa
terraform taint tls_private_key.host_ed25519
# optionally also change var.vm_mac in terraform.tfvars
terraform apply
ssh-keygen -R <old-ip>   # clear the stale known_hosts entry
```

**Run two VMs side-by-side**: set a different `vm_mac` in each stack/tfvars
(e.g. `52:54:00:fe:da:44`) so they don't both claim the same lease.
