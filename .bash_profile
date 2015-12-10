# Bash Configuration

# Modify Terminal Prompt and Color
ENDCOLOR="\[\e[0m\]"
UNDERLINEBLUE="\[\e[0;34m\]"
PS1="[\t @\u @$UNDERLINEBLUE\w$ENDCOLOR]\$ ";

# Modify the color of LS
export CLICOLOR=1
export TERM=xterm-256color
export LSCOLORS=ExFxCxDxBxegedabagacad

# Use ctags-exuberant CTAGS as default
export PATH="/usr/local/bin:$PATH"

##
# Your previous /Users/neroam/.bash_profile file was backed up as /Users/neroam/.bash_profile.macports-saved_2014-03-18_at_12:40:52
##

# MacPorts Installer addition on 2014-03-18_at_12:40:52: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

# added by Anaconda 2.2.0 installer
export PATH="/Users/neroam/anaconda/bin:$PATH"

# added for Caffe installation
export DYLD_FALLBACK_LIBRARY_PATH="$HOME/anaconda/lib:/usr/local/lib:/usr/lib"
export PYTHONPATH=~/Projects/caffe/python:$PYTHONPATH
export PATH="/Users/neroam/Projects/caffe/build/install/bin:$PATH"

# tmux
alias dev="ssh neroam.com -t 'if tmux has-session -t main; then tmux -2CC attach -t main; else tmux -2CC new -d -s main; fi'"
#alias dev="if tmux has-session -t main; then tmux -2CC attach -t main; else tmux -2CC new -s main; fi"
