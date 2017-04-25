# Common config

is_linux () {
  [[ $('uname') == 'Linux' ]];
}

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Encoding
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"

# --------------------- Theme ----------------------------
# POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_MODE='awesome-patched'
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs pyenv vi_mode)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)

# vi_mode
# POWERLEVEL9K_VI_INSERT_MODE_STRING="I"
# POWERLEVEL9K_VI_COMMAND_MODE_STRING="N"
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


# ---------------------------- ENV ----------------------------
export EDITOR='vim'
# ---------------------------- ENV ----------------------------

# Plugins
plugins=(git vi-mode z catimg zsh-autosuggestions zsh-syntax-highlighting zsh-dircolors-solarized)

source $ZSH/oh-my-zsh.sh

if is_osx; then
  source $HOME/.zshrc.mac
elif is_linux; then
  source $HOME/.zshrc.linux
fi

# alias
alias rz="source ~/.zshrc"
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

# ---------------------------- Java ----------------------------
# jenv
if which jenv > /dev/null; then eval "$(jenv init -)"; fi
# ---------------------------- Java ----------------------------

# ---------------------------- Python ----------------------------
# pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# pyenv-virtualenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
# ---------------------------- Python ----------------------------

# ---------------------------- Node ----------------------------
# nodenv
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi
# ---------------------------- Node ----------------------------

# ---------------------------- Ruby ----------------------------
# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# ---------------------------- Ruby ----------------------------
