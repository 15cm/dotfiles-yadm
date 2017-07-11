# --------------------- Common Config  ---------------------
# Fix for emacs tramp mode
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
# _____________________ Common Config  _____________________

# --------------------- Functions ---------------------
is_linux () {
  [[ $('uname') == 'Linux' ]];
}

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

# Lazy Load to speed up zsh start
# Authors:
#   xcv58 <i@xcv58.com>
# Source:
#   https://github.com/xcv58/prezto/blob/master/modules/lazy-load/init.zsh

function lazy_load() {
  local load_func=${1}
  local lazy_func="lazy_${load_func}"

  shift
  for i in ${@}; do
    alias ${i}="${lazy_func} ${i}"
  done

  eval "
    function ${lazy_func}() {
        unset -f ${lazy_func}
        lazy_load_clean $@
        eval ${load_func}
        unset -f ${load_func}
        eval \$@
    }
    "
}

function lazy_load_clean() {
  for i in ${@}; do
    unalias ${i}
  done
}
# _____________________ Functions _____________________

# --------------------- ENV ---------------------
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
export LOAD_NVM=true

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# pyenv-virtualenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# jenv(lazy load)
export PATH="$HOME/.jenv/bin:$PATH"
function load_jenv() {
  if which jenv > /dev/null; then eval "$(jenv init -)"; fi
}
lazy_load load_jenv jenv java javac

# rbenv(lazy load)
export PATH="$HOME/.rbenv/bin:$PATH"
function load_rbenv() {
  if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
}
lazy_load load_rbenv rbenv ruby gem

# direnv
function load_direnv() {
  if which direnv > /dev/null; then eval "$(direnv hook zsh)"; fi
}
lazy_load load_direnv direnv

# thefuck
function load_thefuck() {
  if which thefuck > /dev/null; then eval "$(thefuck --alias)"; fi
}
lazy_load load_thefuck fuck
# _____________________ ENV _____________________

# --------------------- Theme ---------------------
POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs vi_mode)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs pyenv time)

# icon override
POWERLEVEL9K_VCS_GIT_GITHUB_ICON="\uf408"

# vcs
POWERLEVEL9K_SHOW_CHANGESET=true

# vi_mode
POWERLEVEL9K_DIR_HOME_FOREGROUND="white"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="white"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="white"
POWERLEVEL9K_VI_INSERT_MODE_STRING="I"
POWERLEVEL9K_VI_COMMAND_MODE_STRING="N"

# CMD Exec Time
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='250'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='black'
# _____________________ Theme _____________________

# --------------------- Key map ---------------------
export KEYTIMEOUT=1
bindkey '^h' backward-delete-char
bindkey '^d' delete-char
bindkey '^b' backward-char
bindkey '^f' forward-char
bindkey '^o' forward-word
bindkey '^k' kill-line
# _____________________ Key map _____________________

# --------------------- Plugins ---------------------
plugins=(git vi-mode tmux z zsh-autosuggestions zsh-syntax-highlighting zsh-nvm k)
# _____________________ Plugins _____________________

source $ZSH/oh-my-zsh.sh

# --------------------- Alias ---------------------
alias rz="source ~/.zshrc"
alias vi="vim"
alias ls="colorls -sd"
alias ll="k"
# _____________________ Alias  _____________________

if is_osx; then
  source $HOME/.zshrc.mac
elif is_linux; then
  source $HOME/.zshrc.linux
fi

# --------------------- 'fzf' and 'z' ---------------------
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
# _____________________ 'fzf' and 'z' _____________________
