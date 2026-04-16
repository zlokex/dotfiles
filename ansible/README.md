# Ansible Setup

Reproduces this workstation on a fresh **Fedora** install: COPR repos, dnf
packages, flatpaks, Nerd Fonts, dotfiles (stowed from the repo), zsh as the
default shell, nvm + Node LTS, JetBrains Toolbox, GNOME extensions, and
docker/libvirt services.

## Quickstart

Run `bootstrap.sh` — it installs `ansible` + `git`, clones the repo if needed,
pulls collection dependencies, and runs the playbook:

```bash
curl -fsSL https://raw.githubusercontent.com/zlokex/dotfiles/master/ansible/bootstrap.sh | bash
```

If the repo is already cloned:

```bash
~/dotfiles/ansible/bootstrap.sh
```

The playbook targets `localhost` via `ansible_connection=local`. `bootstrap.sh`
invokes `ansible-playbook -K`, which prompts for the sudo password — most roles
need `become: true`.

> **Headless / cloud VMs.** On Fedora Cloud images, typing an uninstalled
> command triggers `PackageKit-command-not-found`, which tries to install via
> PackageKit and requires a graphical polkit agent. Without one (SSH-only
> sessions) you get `Failed to obtain authentication`. Never install via the
> `[N/y]` prompt there — use `sudo dnf install -y <pkg>` explicitly, or just
> run `bootstrap.sh` which handles ansible/git for you.

## Running pieces by hand

**Prerequisite:** `ansible-core` (or `ansible`) must already be installed.
`bootstrap.sh` handles this; if you skip it, run
`sudo dnf install -y ansible-core git` first. Do **not** accept the
command-not-found prompt on a headless VM — see the warning above.

Each role is tagged so pieces can be applied individually:

```bash
cd ~/dotfiles/ansible
ansible-galaxy collection install -r requirements.yml   # once
ansible-playbook -K site.yml --tags fonts
ansible-playbook -K site.yml --tags dotfiles,shell
ansible-playbook -K site.yml --skip-tags virt,office
ansible-playbook -K site.yml --tags jetbrains-plugins   # only after IDE is installed
```

Available tags: `copr`, `dnf`, `flatpak`, `fonts`, `dotfiles`, `shell`, `nvm`,
`neovim`, `vim`, `jetbrains`, `gnome`, `services`, plus the dnf sub-tags
`cli`, `dev`, `docker`, `gui`, `virt`, `office`.

## What is _not_ automated

- **SSH / GPG keys, cloud credentials** — out of scope, restore manually.
- **JetBrains IDEs** — only Toolbox is installed; pick IDEs + license in the GUI.
- **NVIDIA drivers, docker-desktop** — omitted from defaults (licensing/hardware).
- **GNOME extensions** — installed best-effort via `gext`; if a version mismatch
  blocks one, install it from [extensions.gnome.org](https://extensions.gnome.org).

## Post-install

1. Log out and back in so the new shell (zsh), group memberships (`docker`,
   `libvirt`, `kvm`), and zinit bootstrap take effect.
2. Open `nvim` once — lazy.nvim and Mason finish setup on first launch.
3. Open Toolbox and install your IntelliJ IDE; then rerun
   `ansible-playbook -K site.yml --tags jetbrains-plugins` to install IdeaVim.
4. **GNOME extensions** — log out and log back in after the first run. GNOME
   Shell on Wayland can't hot-reload freshly installed extensions; they only
   activate on the next session.

## Layout

```
ansible/
├── ansible.cfg
├── inventory.ini
├── requirements.yml
├── site.yml
├── bootstrap.sh
├── group_vars/all.yml
└── roles/{copr,dnf_packages,flatpak,fonts,dotfiles,shell,
          nvm,neovim,vim,jetbrains,gnome,services}/
```

Package lists, COPR repos, extension UUIDs, and plugin names all live in
`group_vars/all.yml` — edit there, not inside roles.
