# Fix for emacs tramp mode
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# Common config

is_linux () {
  [[ $('uname') == 'Linux' ]];
}

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# ---------------------------- ENV ----------------------------
export EDITOR='vim'
export _Z_DATA="$HOME/.z/.z"
. ~/.z/z.sh

# Encoding
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"

# Colors
export TERM="xterm-256color"

# Tmux Plugin
ZSH_TMUX_AUTOSTART=true

# nvm(loaded with zsh-nvm plugin)
export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true

# ---------------------------- ENV ----------------------------

# --------------------- Theme ----------------------------
# POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_MODE='awesome-patched'
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs pyenv vi_mode)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)

# OS icon
POWERLEVEL9K_OS_ICON_BACKGROUND="251"
POWERLEVEL9K_OS_ICON_FOREGROUND="blue"

# vi_mode
POWERLEVEL9K_DIR_HOME_FOREGROUND="white"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="white"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="white"

# CMD Exec Time
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='250'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='black'

# --------------------- Theme ----------------------------

# bindings
export KEYTIMEOUT=0
bindkey '^h' backward-delete-char
bindkey '^d' delete-char
bindkey '^b' backward-char
bindkey '^f' forward-char
bindkey '^o' forward-word
bindkey '^k' kill-line

# Plugins
plugins=(git vi-mode tmux z zsh-autosuggestions zsh-syntax-highlighting zsh-nvm)

source $ZSH/oh-my-zsh.sh

if is_osx; then
  source $HOME/.zshrc.mac
elif is_linux; then
  source $HOME/.zshrc.linux
fi

# alias
alias rz="source ~/.zshrc"
alias ls="ls --color=auto --group-directories-first --group-directories-first"
alias vi="vim"

# ------------------ 'fzf' and 'z' ----------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
set FZF_CTRL_T_COMMAND="fzf-tmux"
set FZF_CTRL_T_OPTS="-m --cycle --jump-labels=CHARS"
set FZF_CTRL_R_OPTS="-m --cycle --jump-labels=CHARS"

# fdirh() {
#     print -z $(dirs -v |  fzf | sed 's/^\s*[0-9]*\s*//' | sed_unix_path)
# }

alias fzf="fzf-tmux -m --cycle --jump-labels=CHARS"

# using 'fzf' when calling 'z' with no args or no result returned
fun_z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf-tmux +s --tac --query "$*" | sed 's/^[0-9,.]* *//')"
}

fdirz() {
    _z -l 2>&1 | fzf-tmux +s --tac --query "$*" | sed 's/^[0-9,.]* *//'
}
alias j="fun_z"
# ------------------ 'fzf' and 'z' ----------------------------

# -------------------------- direnv ----------------------------
if which direnv > /dev/null; then eval "$(direnv hook zsh)"; fi
# -------------------------- direnv ----------------------------
#
# -------------------------- thefuck ---------------------------
if which thefuck > /dev/null; then eval "$(thefuck --alias)"; fi
# -------------------------- thefuck ---------------------------

# ---------------------------- Java ----------------------------
# jenv
export PATH="$HOME/.jenv/bin:$PATH"
if which jenv > /dev/null; then eval "$(jenv init -)"; fi
# ---------------------------- Java ----------------------------

# ---------------------------- Python ----------------------------
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# pyenv-virtualenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
# ---------------------------- Python ----------------------------

# ---------------------------- Ruby ----------------------------
# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# ---------------------------- Ruby ----------------------------

