# fedora-vm

Terraform stack that provisions a local **Fedora Workstation 43** VM on
KVM/libvirt, managed alongside virt-manager.

The VM boots from the upstream Fedora 43 Cloud Base qcow2 and uses cloud-init
to install `@workstation-product-environment`, enable GDM, inject your SSH
key, and reboot into a graphical GNOME session.

## Quick start

```sh
cd terraform/fedora-vm
./bootstrap.sh
```

`bootstrap.sh` is idempotent and Fedora-only. It:

1. Installs `terraform` + the libvirt/QEMU/virt-manager stack
   (`libvirt-daemon-kvm`, `qemu-kvm`, `qemu-guest-agent`, `virt-install`,
   `virt-manager`, `virt-viewer`) — the same set the ansible
   `dnf_packages` + `services` roles provide.
2. Enables `libvirtd` and adds `$USER` to the `libvirt` + `kvm` groups.
   If groups changed, it tells you to re-login and re-run; terraform
   can't talk to `qemu:///system` until the new groups are active.
3. Prompts you for the `fedora` user's password (via `openssl passwd -6`,
   hidden input, asked twice) and then walks through each optional
   override (`vm_name`, `vcpus`, `memory_mib`, `disk_gib`,
   `ssh_public_key_path`) — press ENTER to accept the default shown in
   brackets. Writes `terraform.tfvars` with mode 600.
4. Runs `terraform init` + `terraform apply` (which shows the plan and
   waits for your `yes`).

First apply takes 5–15 min: base image download (~500 MB), cloud-init
`dnf group install workstation-product-environment` (~1–2 GB), then a
reboot into GDM.

## Manual usage

Skip `bootstrap.sh` if you've already run this repo's Ansible play
(`site.yml`) — the prereqs are in place. From there:

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
and you'd hit `HOST IDENTIFICATION HAS CHANGED`. Instead, a `null_resource`
with `local-exec` runs `ssh-keygen` once into `host-keys/` (RSA 4096 +
ED25519), and cloud-init writes those into `/etc/ssh/ssh_host_*` on each
boot. The keys are plain files on disk — outside Terraform's resource graph
— so they survive `terraform destroy`, and a rebuilt VM presents the same
fingerprint as the last one.

**Security note**: the VM's host private keys live in
`terraform/fedora-vm/host-keys/` (mode 600, `.gitignored`) — **not** in
`terraform.tfstate`. Don't commit the directory or copy it around; if you
move the VM to another workstation and want to keep its identity, copy
`host-keys/` over deliberately.

**Rotate the VM's identity** (e.g. after you've handed it off):

```sh
rm -rf host-keys/             # next apply regenerates via ssh-keygen
# optionally also change var.vm_mac in terraform.tfvars
terraform apply
ssh-keygen -R <old-ip>        # clear the stale known_hosts entry
```

**Run two VMs side-by-side**: set a different `vm_mac` in each stack/tfvars
(e.g. `52:54:00:fe:da:44`) so they don't both claim the same lease.
