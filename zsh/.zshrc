# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=10000
HISTSIZE=9999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward


# ---- lsd (better ls) ----
alias ls="lsd --color=always --long --git --icon=always"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
alias cd="z"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

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
    chafa --fit-width --size=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}
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

# ----- Bat (better cat) -----
export BAT_THEME=tokyonight_night

source ~/fzf-git.sh/fzf-git.sh


# Prompt
#export PS1='[%*] [%n@%m]%~%#'
#PROMPT="[%*] %n@%m %~%# "

#version control in prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '
# End of Prompt


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# thefuck alias (Autocrrect mistyped commands)
eval $(thefuck --alias)
eval $(thefuck --alias fk)



