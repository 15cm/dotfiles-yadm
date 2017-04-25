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
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
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

# alias
alias p="proxychains4 -q"
alias ep="HTTP_PROXY=http://127.0.0.1:1090"
alias vi="vim"
alias mux="tmuxinator"
alias rz="source ~/.zshrc"
alias brew="p brew"
alias git="p git"
alias em="emacsclient -t"
alias ls="ls --color=auto --group-directories-first --group-directories-first"


# Auto completion
fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit && compinit -i
source ~/.zsh/completion/tmuxinator.zsh

# use coreutils without 'g' prefix
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

# user path
export PATH="/usr/local/bin:$PATH:/usr/local/script"

# Path for aria2 build
export PATH="$PATH:/usr/local/opt/gettext/bin:/usr/local/aria2/bin"

# GNU Utils Before Load Zsh Plugins {
# alias dircolors="gdircolors"
# }

# GNU Utils After Load Zsh Plugins {
# wrap find with gfind, result always with quotes
# alias xargs="gxargs "
# alias sed="gsed"
# sed alias
# alias sed_unix_path="sed 's/ /\\\ /g'"
#}

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

# Spacemacs tramp connection
export PATH="/usr/local/sbin:$PATH"
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

source $HOME/.cargo/env

# added by travis gem
[ -f /$HOME/.travis/travis.sh ] && source /$HOME/.travis/travis.sh


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
