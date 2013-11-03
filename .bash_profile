# Bash Configuration

# Modify Terminal Prompt and Color
ENDCOLOR="\[\e[0m\]"
UNDERLINEBLUE="\[\e[0;34m\]"
PS1="\n[\t @\u @$UNDERLINEBLUE\w$ENDCOLOR]\$ ";

# Modify the color of LS
export CLICOLOR=1
export TERM=xterm-256color
export LSCOLORS=ExFxCxDxBxegedabagacad

# Use ctags-exuberant CTAGS as default
export PATH="/usr/local/bin:$PATH"
