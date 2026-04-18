#!/usr/bin/env bash
# Bootstraps a Fedora workstation end-to-end for this stack:
#
#   1. installs terraform + the libvirt/QEMU/virt-manager stack
#   2. enables libvirtd, adds $USER to the libvirt/kvm groups
#   3. generates terraform.tfvars (prompts for the fedora-user password,
#      offers to override each optional default)
#   4. runs terraform init + apply
#
# Safe to re-run: every step is idempotent. Steps 1–2 are the same as
# the ansible roles `dnf_packages` + `services` but don't require
# ansible to be installed first.
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
    echo "!!! This script only targets Fedora (dnf not found)." >&2
    exit 1
fi

PACKAGES=(
    terraform
    libvirt-daemon-kvm
    qemu-kvm
    qemu-guest-agent
    virt-install
    virt-manager
    virt-viewer
)

missing=()
for pkg in "${PACKAGES[@]}"; do
    if ! rpm -q "$pkg" >/dev/null 2>&1; then
        missing+=("$pkg")
    fi
done

if [ "${#missing[@]}" -gt 0 ]; then
    echo ">>> Installing: ${missing[*]}"
    sudo dnf install -y "${missing[@]}"
else
    echo ">>> All packages already installed."
fi

if ! systemctl is-enabled --quiet libvirtd.service; then
    echo ">>> Enabling libvirtd..."
    sudo systemctl enable --now libvirtd.service
elif ! systemctl is-active --quiet libvirtd.service; then
    echo ">>> Starting libvirtd..."
    sudo systemctl start libvirtd.service
fi

groups_changed=0
for grp in libvirt kvm; do
    if ! id -nG "$USER" | tr ' ' '\n' | grep -qx "$grp"; then
        echo ">>> Adding $USER to $grp group..."
        sudo usermod -aG "$grp" "$USER"
        groups_changed=1
    fi
done

if [ "$groups_changed" -eq 1 ]; then
    cat <<EOF

>>> Group membership changed. Log out and back in (or start a fresh shell
    with \`newgrp libvirt\`) and re-run this script — terraform can't talk
    to qemu:///system until the new groups are active in your session.
EOF
    exit 0
fi
echo ">>> Group membership already correct."

# ----- libvirt default network + storage pool --------------------------------

if ! sudo virsh net-info default >/dev/null 2>&1; then
    echo ">>> Defining default libvirt NAT network..."
    sudo virsh net-define /usr/share/libvirt/networks/default.xml
else
    echo ">>> Default libvirt network already defined."
fi
net_info=$(sudo virsh net-info default 2>/dev/null || true)
if ! grep -qE '^Active:[[:space:]]+yes' <<<"$net_info"; then
    echo ">>> Starting default libvirt network..."
    sudo virsh net-start default
else
    echo ">>> Default libvirt network already active."
fi
sudo virsh net-autostart default >/dev/null

if ! sudo virsh pool-info default >/dev/null 2>&1; then
    echo ">>> Creating default libvirt storage pool at /var/lib/libvirt/images..."
    sudo virsh pool-define-as default dir --target /var/lib/libvirt/images
    sudo virsh pool-build default
    sudo virsh pool-start default
else
    echo ">>> Default libvirt storage pool already defined."
fi
pool_info=$(sudo virsh pool-info default 2>/dev/null || true)
if ! grep -qE '^State:[[:space:]]+running' <<<"$pool_info"; then
    echo ">>> Starting default libvirt storage pool..."
    sudo virsh pool-start default
else
    echo ">>> Default libvirt storage pool already running."
fi
sudo virsh pool-autostart default >/dev/null

cd "$(dirname "$(readlink -f "$0")")"

# ----- terraform.tfvars -------------------------------------------------------

skip_tfvars=0
if [ -f terraform.tfvars ]; then
    echo
    echo ">>> terraform.tfvars already exists."
    read -r -p ">>> Overwrite it? [y/N] " reply
    case "$reply" in
    [yY] | [yY][eE][sS]) ;;
    *)
        echo ">>> Keeping existing terraform.tfvars."
        skip_tfvars=1
        ;;
    esac
fi

if [ "$skip_tfvars" -eq 0 ]; then
    echo
    echo ">>> SHA-512 hash for the fedora user (used for GDM / console login)."
    echo "    You'll be prompted twice; input is hidden."
    password_hash=$(openssl passwd -6)

    prompt_default() {
        # usage: prompt_default "label" "default"
        local label="$1" default="$2" answer
        read -r -p "    $label [$default]: " answer
        printf '%s' "${answer:-$default}"
    }

    echo
    echo ">>> Optional overrides (ENTER to keep the default):"
    vm_name=$(prompt_default "vm_name" "fedora43-ws")
    vcpus=$(prompt_default "vcpus" "4")
    memory_mib=$(prompt_default "memory_mib" "8192")
    disk_gib=$(prompt_default "disk_gib" "80")
    ssh_public_key_path=$(prompt_default "ssh_public_key_path" "~/.ssh/id_ed25519.pub")

    # Generate the default ed25519 keypair if it's missing so
    # `file(pathexpand(...))` in main.tf doesn't fail on a fresh install.
    if [ "$ssh_public_key_path" = "~/.ssh/id_ed25519.pub" ] && [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
        echo ">>> No ~/.ssh/id_ed25519.pub found; generating one (will be injected into the VM)."
        echo "    ssh-keygen will prompt for a passphrase to encrypt the private key."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        ssh-keygen -t ed25519 -C "$USER@$(hostname -s)" -f "$HOME/.ssh/id_ed25519"
    fi

    umask 077
    cat >terraform.tfvars <<EOF
user_password_hash  = "$password_hash"
vm_name             = "$vm_name"
vcpus               = $vcpus
memory_mib          = $memory_mib
disk_gib            = $disk_gib
ssh_public_key_path = "$ssh_public_key_path"
EOF
    echo ">>> Wrote terraform.tfvars (mode 600)."
fi

# ----- terraform init + apply ------------------------------------------------

echo
echo ">>> Running terraform init..."
terraform init

echo
echo ">>> Running terraform apply (review the plan, then type 'yes' to proceed)..."
terraform apply

echo
echo ">>> Done. Reach the VM with:"
echo "      $(terraform output -raw ssh_command 2>/dev/null || echo 'terraform output ssh_command')"
