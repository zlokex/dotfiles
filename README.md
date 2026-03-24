# Dotfiles

**WARNING**: These are the installation instructions for myself, not for you. 
You should have your own repository and get inspired by this one. 
If you have any questions, feel free to open issues.

## Dependecies

### Stow (Optional)

**Fedora**

```bash
sudo dnf install stow
```

## Setup

Clone the repository and run stow */ to generate symlinks in the correct folders.

```bash
git clone this-repo
cd repo
stow */
```


# Shell (Zsh)

## Install

**Fedora**

```bash
sudo dnf install zsh
```

## Dependencies

### lsd (Better ls)

**Fedora**

```bash 
sudo dnf install lsd
```

### Zoxide (Better cd)

**Fedora**

```bash
sudo dnf install zoxide
```

### fzf (Fuzzy finder)

**Fedora**

```bash
sudo dnf install fzf
```

### fd (find alternative)

**Fedora**

```bash
sudo dnf install fd-find
```

### fzf-git

```bash
git clone https://github.com/junegunn/fzf-git.sh.git ~/fzf-git.sh/
```

### bat (Better cat)

**Fedora**

```bash
sudo dnf install bat
```

### thefuck (Autocorrect mistyped commands)

**Fedora**

```bash
sudo dnf install thefuck
```

## Setup

# Git

## Install

```bash
sudo dnf install git
```

## Dependencies

### Delta

**Fedora**

```bash
sudo dnf install git-delta
```

# Terminal (Alacritty)

Config file is under dotfiles/alacritty/.config/alacritty/alacritty.toml

## Install

**Fedora**

```bash
# Enable copr repository (Use at your own risk)
sudo dnf copr enable pschyska/alacritty
sudo dnf install alacritty
```


## Dependencies

### Nerd Font

### Clone the Nerd Fonts Repository

Use the sparse-checkout to avoid downloading the entire repository

```bash
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git ~/nerd-fonts
cd ~/nerd-fonts
# Spare checkout only the Meslo fonts
git sparse-checkout add patched-fonts/Meslo
```
### Install the Font

```bash
# Install Meslo to ~/.local/share/fonts
./install.sh Meslo
# Refresh the system's font cache to recognize the new fonts
fc-cache -fv
# Verify installation
c-list | grep "Meslo"
```
## Setup

# Vimx

Vim with clipboard support

## Install

**Fedora**

```bash
sudo dnf install vim-X11
```

**Fedora**

```bash
sudo dnf install vim-X11
```

## Dependencies

## Setup

# Tmux

## Install

## Dependencies

## Setup

# IDE (IntelliJ)

This repository includes a dotfile for the ideavim plugin for intelliJ. It is located under dotfiles/ideavim/.ideavimrc

## Install

1. Download the Linux verion of JetBrains Toolbox from the official JetBrains site.
2. Extract and install the downloaded .tar.gz file

```bash
# Extract the downloaded .tar.gz file
tar -xzf jetbrains-toolbox-*.tar.gz
# Run the application (This will launch the application and integrate it in ~/.local/share/JetBrains/Toolbox
./jetbrains-toolbox-*/jetbrains-toolbox
```
3. Install your IDE of choice (e.g. IntelliJ IDEA) from the Toolbox

## Dependencies

### IdeaVim (Plugin)

1. Open Setings with Ctrl+Alt+S
2. Navigate to the **Plugins** section
3. Switch to the **Marketplace** tab.
4. Use the search bar to search for IdeaVim
5. Click **Install**

TODO: Add plugin folder to repo?


