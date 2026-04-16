#!/usr/bin/env bash
# Bootstraps a fresh Fedora install by cloning the dotfiles repo and
# running the Ansible playbook against localhost.
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/zlokex/dotfiles.git}"
DOTFILES_PATH="${DOTFILES_PATH:-$HOME/dotfiles}"

if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo ">>> Installing ansible + git..."
    sudo dnf install -y ansible git
fi

if [ ! -d "$DOTFILES_PATH/.git" ]; then
    echo ">>> Cloning $DOTFILES_REPO into $DOTFILES_PATH..."
    git clone "$DOTFILES_REPO" "$DOTFILES_PATH"
fi

cd "$DOTFILES_PATH/ansible/fedora-workstation"

echo ">>> Installing Ansible collection dependencies..."
ansible-galaxy collection install -r requirements.yml

echo ">>> Running playbook (you will be prompted for sudo)..."
exec ansible-playbook -K site.yml "$@"
