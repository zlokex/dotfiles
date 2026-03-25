# Custom settings that override p10k.zsh goes here since p10k.zsh is generated with p10k configure

# Background color of directory in prompt
typeset -g POWERLEVEL9K_DIR_BACKGROUND=60

# Fix bug where powerlevel10k prompt duplicates and renders in wrong areas upon resizing window.
# The issue issue arises when a terminal reflows Zsh prompt upon resizing, but is more prone to
# appear with powerlevel10k prompts than a normal prompt.
# The following line fixes the issue for kitty, but the bug remains for alacritty and wezterm.
# See: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#mitigation
typeset -g POWERLEVEL9K_TERM_SHELL_INTEGRATION=true