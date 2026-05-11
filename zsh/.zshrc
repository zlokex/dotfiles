####################
#   ____   _       #
#  |_  /__| |_     #
#   / /(_-< ' \    #
#  /___/__/_||_|   #
#                  #
####################

# Powerlevel10k instant prompt ------------------------------------------------------------------------------------- {{{

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ $TERM == "xterm-kitty" ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# }}}

# ----- Bat (better cat) -----
export BAT_THEME=tokyonight_night

# ----- Zsh autosuggestions -----
# Change autosuggestions to blue
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=12,bold'

# Plugins / Themes / Imports --------------------------------------------------------------------------------------- {{{

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

if [[ $TERM == "xterm-kitty" ]]; then
  # Add in Powerlevel10k
  zinit ice depth=1; zinit light romkatv/powerlevel10k

  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  # Source custom p10k configurations
  [[ ! -f ~/.zsh/.p10k_custom.zsh ]] || source ~/.zsh/.p10k_custom.zsh
else
  # Fallback prompt
  source ~/.zsh/custom-prompt.zsh
fi

# Load completions
autoload -Uz compinit && compinit

#  (See: https://github.com/aloxaf/fzf-tab?tab=readme-ov-file#install for instructions on where to place)
zinit light Aloxaf/fzf-tab
setopt GLOB_DOTS # Include hidden files in globbing (for fzf-tab)

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

zinit light z-shell/F-Sy-H # Syntax highlighting

zinit light junegunn/fzf-git.sh #(Ctrl-G ? to show available bindings)
# Unbind ^G from send-break so it works as a prefix key for fzf-git
bindkey -rM emacs '^G'
bindkey -rM viins '^G'
bindkey -rM vicmd '^G'

# Add in snippets
zinit snippet OMZL::git.zsh # Load the Git library from Oh My Zsh (https://github.com/ohmyzsh/ohmyzsh)
zinit snippet OMZP::sudo # Double press Esc to prepend command with sudo (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo)
zinit snippet OMZP::azure # Adds Azure CLI autocompletion and aliases (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/azure)
zinit snippet OMZP::kubectl # Adds kubectl autocompletion and aliases (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl

zinit cdreplay -q # Replay compdefs (to be done after compinit). -q – quiet.

# }}}

# History setup ---------------------------------------------------------------------------------------------------- {{{

HISTFILE=$HOME/.zhistory
SAVEHIST=10000
HISTSIZE=9999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# }}}

# Autocompletion --------------------------------------------------------------------------------------------------- {{{

# autoload -Uz +X compinit && compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

command -v docker >/dev/null 2>&1 && source <(docker completion zsh)

# Azure CLI completion (Fedora ships this with the `azure-cli` RPM)
if [[ -f /usr/share/bash-completion/completions/azure-cli ]]; then
  autoload -U +X bashcompinit && bashcompinit
  source /usr/share/bash-completion/completions/azure-cli
fi

# }}}

# FZF -------------------------------------------------------------------------------------------------------------- {{{

# Set up fzf key bindings and fuzzy completion
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="\
--color=fg:${fg},bg:${bg},hl:${purple} \
--color=fg+:${fg},bg+:${bg_highlight},hl+:${purple} \
--color=info:${blue},prompt:${cyan},pointer:${cyan} \
--color=marker:${cyan},spinner:${cyan},header:${cyan}"

show_file_or_dir_preview="\
if [ -d {} ]; then
    lsd --tree --color=always {} | head -200
elif file -b --mime-type {} | grep -q ^image/; then
    chafa --format=symbols --fit-width --size=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}
else
    bat -n --color=always --line-range :500 {}
fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'lsd --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
# Enabled by command **<TAB>
# Has default completions for: export, unset, unalias, ssh, telnet & kill
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'lsd --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# }}}

# Kubectl ---------------------------------------------------------------------------------------------------------- {{{

# Set KUBECONFIG to use kubeconfig in current directory (via relative path)
export KUBECONFIG=./kubeconfig

# }}}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PATH ------------------------------------------------------------------------------------------------------------- {{{

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"
export PATH=$PATH:$(go env GOPATH)/bin

# }}}

# Environment Variables -------------------------------------------------------------------------------------------- {{{

# Set Default editor to nvim
export EDITOR="nvim"
export VISUAL="nvim"

# Disable telemetry for tools that respects this variable (e.g. gh)
export DO_NOT_TRACK=true

# }}}

# Aliases ---------------------------------------------------------------------------------------------------------- {{{

# ----- lsd (better ls) -----
alias ls="lsd --color=always --long --git --icon=always"

alias k=kubectl

# thefuck alias (Autocrrect mistyped commands)
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
  eval "$(thefuck --alias fk)"
fi

if [[ $TERM == "xterm-kitty" ]]; then
    # For SSH compatibility
    # alias ssh="kitten ssh"
    alias ssh="TERM=xterm-256color command ssh"
fi

test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# ----- Claude Code: general-purpose (non-project) session -----
# Runs Claude in ~/claude-sandbox so general chats stay isolated from any
# project's sessions/memory. Subshell preserves the current terminal's cwd.
# builtin cd bypasses the `cd`->`z` (zoxide) alias.
ask()   { mkdir -p ~/claude-sandbox && (builtin cd ~/claude-sandbox && claude "$@"); }
ask-c() { mkdir -p ~/claude-sandbox && (builtin cd ~/claude-sandbox && claude --continue); }
ask-r() { mkdir -p ~/claude-sandbox && (builtin cd ~/claude-sandbox && claude --resume); }

# }}}

# Keep near end of file (needs to be after compinit)
# Gate on interactive shells so non-interactive subshells (e.g. Claude tools)
# don't trigger zoxide's hook-not-registered warning when cd is called.
if [[ -o interactive ]] && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi
