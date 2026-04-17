# Dotfiles

**WARNING**: These are the installation instructions for myself, not for you.
You should have your own repository and get inspired by this one.
If you have any questions, feel free to open issues.

## Automated setup (Ansible)

Reproduces this workstation on a fresh **Fedora** install — COPR repos, dnf
packages, flatpaks, Nerd Fonts, dotfiles (stowed), zsh, nvm, JetBrains Toolbox,
GNOME extensions, docker/libvirt. See
[`ansible/fedora-workstation/README.md`](ansible/fedora-workstation/README.md)
for details and tag-scoped reruns.

```bash
# Fresh machine — installs ansible + git, clones the repo, runs site.yml
curl -fsSL https://raw.githubusercontent.com/zlokex/dotfiles/master/ansible/fedora-workstation/bootstrap.sh | bash

# Repo already cloned
~/dotfiles/ansible/fedora-workstation/bootstrap.sh
```

Log out and back in afterwards so the new shell, group memberships
(`docker`, `libvirt`, `kvm`), and GNOME extensions take effect.

## Local Fedora VM (Terraform)

Provisions a local **Fedora Workstation 43** VM on KVM/libvirt — useful for
testing the Ansible play end-to-end. Prerequisites (`libvirt`, `virt-install`,
`terraform`) are covered by the Ansible play above. See
[`terraform/fedora-vm/README.md`](terraform/fedora-vm/README.md) for SSH host
key pinning, rebuild/rotation, and notes.

```bash
cd terraform/fedora-vm
openssl passwd -6                     # hash for the `fedora` user
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars              # paste hash, tweak sizes / ssh key path
terraform init
terraform apply                       # 5–15 min on first run
terraform output ssh_command
```

## Manual steps

The Ansible play covers everything below. Use these only when bootstrapping
a host without Ansible, or when installing a single tool by hand.

### Stow

```bash
sudo dnf install stow
git clone this-repo
cd repo
stow alacritty bash eza git ideavim kitty lsd nvim tridactyl vim wezterm yazi zsh
```

### Shell (Zsh)

```bash
sudo dnf install zsh lsd zoxide fzf fd-find bat thefuck
```

### Git

```bash
sudo dnf install git git-delta
```

### Terminal (Alacritty)

Config: `alacritty/.config/alacritty/alacritty.toml`.

```bash
sudo dnf copr enable pschyska/alacritty
sudo dnf install alacritty
```

### Terminal (WezTerm)

```bash
sudo dnf copr enable wezfurlong/wezterm-nightly
sudo dnf install wezterm
```

### Nerd Font (Meslo)

Sparse-checkout avoids downloading the full Nerd Fonts repo.

```bash
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git ~/nerd-fonts
cd ~/nerd-fonts
git sparse-checkout add patched-fonts/Meslo
./install.sh Meslo
fc-cache -fv
fc-list | grep Meslo
```

### Vimx (Vim with clipboard)

```bash
sudo dnf install vim-X11
```

### IDE (JetBrains Toolbox + IntelliJ)

Config: `ideavim/.ideavimrc`.

1. Download Linux JetBrains Toolbox from the official site.
2. Extract and launch — it integrates under `~/.local/share/JetBrains/Toolbox`.

```bash
tar -xzf jetbrains-toolbox-*.tar.gz
./jetbrains-toolbox-*/jetbrains-toolbox
```

3. Install IntelliJ IDEA from Toolbox, then install the plugins:

```bash
idea installPlugins IdeaVim
idea installPlugins com.joshestein.ideavim-quickscope
idea installPlugins com.magidc.ideavim.anyObject
idea installPlugins com.yelog.ideavim.cmdfloat
idea installPlugins com.julienphalip.ideavim.peekaboo
idea installPlugins com.andrewbrookins.wrap_to_column
```