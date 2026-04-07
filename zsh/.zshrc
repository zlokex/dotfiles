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
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=blue'

# Plugins / Themes / Imports --------------------------------------------------------------------------------------- {{{

source ~/.zsh/plugins/fzf-git.sh/fzf-git.sh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/F-Sy-H/F-Sy-H.plugin.zsh

if [[ $TERM == "xterm-kitty" ]]; then
  source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme

  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  # Source custom p10k configurations
  [[ ! -f ~/.zsh/.p10k_custom.zsh ]] || source ~/.zsh/.p10k_custom.zsh
else
  # Fallback prompt
  source ~/.zsh/custom-prompt.zsh
fi

# }}}

# History setup ---------------------------------------------------------------------------------------------------- {{{

HISTFILE=$HOME/.zhistory
SAVEHIST=10000
HISTSIZE=9999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# }}}

# Autocompletion --------------------------------------------------------------------------------------------------- {{{

autoload -Uz +X compinit && compinit

# Enable the interactive selection menu
zstyle ':completion:*' menu select

zmodload zsh/complist # Provides menuselect keymap
# Vim keybindings for the selection menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
# }}}

# FZF -------------------------------------------------------------------------------------------------------------- {{{

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

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

# Add kubectl autocompletion
source <(kubectl completion zsh)

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

# Aliases ---------------------------------------------------------------------------------------------------------- {{{

# ----- lsd (better ls) -----
alias ls="lsd --color=always --long --git --icon=always"

# ----- Zoxide (better cd) ----
alias cd="z"

alias k=kubectl

# thefuck alias (Autocrrect mistyped commands)
eval $(thefuck --alias)
eval $(thefuck --alias fk)

if [[ $TERM == "xterm-kitty" ]]; then
    # For SSH compatibility
    # alias ssh="kitten ssh"
    alias ssh="TERM=xterm-256color command ssh"
fi

# }}}

# Keep near end of file (needs to be after compinit)
eval "$(zoxide init zsh)"
