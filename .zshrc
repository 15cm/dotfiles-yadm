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
export NVM_LAZY_LOAD=true
# _____________________ ENV _____________________

# --------------------- PATH ---------------------
export PATH="/usr/local/bin:$PATH"
# Path for powerline on mac
export PATH="$PATH:$HOME/Library/Python/2.7/bin"
# Path for go
export PATH="$PATH:$HOME/go/bin"
# _____________________ PATH _____________________

# --------------------- Plugins ---------------------
# Env
ZSH_AUTOSUGGEST_USE_ASYNC=true

plugins=(git tmux z zsh-autosuggestions zsh-syntax-highlighting zsh-nvm cd-gitroot zce)
# _____________________ Plugins _____________________

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# --------------------- Key map ---------------------
export KEYTIMEOUT=5
# Updates editor information when the keymap changes.
function zle-keymap-select() {
  zle reset-prompt
  zle -R
}
zle -N zle-keymap-select

function vi_mode_prompt_info() {
  echo "${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle &&  zle -R
}

bindkey -v
autoload -Uz edit-command-line
bindkey -M vicmd '^v' edit-command-line

bindkey '^p' up-history
bindkey '^n' down-history

bindkey '^h' backward-delete-char
bindkey '^d' delete-char
bindkey '^b' backward-char
bindkey '^f' forward-char
bindkey '^o' forward-word
bindkey '^k' kill-line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# zle functions
# select quoted
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
	for c in {a,i}{\',\",\`}; do
	  bindkey -M $m $c select-quoted
	done
done

# select bracketed
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
	for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
	  bindkey -M $m $c select-bracketed
	done
done

# surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -a S add-surround

# zce
bindkey -M vicmd 't' zce

# _____________________ Key map _____________________

# --------------------- ENV 2 ---------------------
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
# _____________________ ENV 2 _____________________

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# --------------------- Alias ---------------------
alias rz="source ~/.zshrc"
alias vi="vim"
# alias ll="k"
alias st="~/dotfiles-helper/switch-theme.sh"
alias gcmsg!="git commit --allow-empty-message -m ''"
alias ew="emacsclient -s misc -t "
alias more="more -R"
alias ccat="ccat -C always"
# _____________________ Alias  _____________________

# --------------------- colorls ---------------------
if which colorls > /dev/null; then
  alias ls="colorls --sd"
  alias ll="colorls -l --sd"
  alias la="colorls -lA --sd"
  alias tree="colorls --sd --tree 2>&1"
  _tree_cmd="colorls --sd --tree"
else
  alias ls="ls --color=tty --group-directories-first"
  alias ll="ls -lh --group-directories-first"
  alias la="ls -lAh --group-directories-first"
  _tree_cmd="tree -C"
fi
# _____________________ colorls _____________________

# --------------------- fzf and z ---------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export FZF_TMUX=1

export FZF_DEFAULT_OPTS="-m --bind=ctrl-d:page-down,ctrl-u:page-up,ctrl-k:kill-line,pgup:preview-page-up,pgdn:preview-page-down,ctrl-space:toggle-all"
export FZF_CTRL_T_OPTS="--preview '(([ -f {} ] && (highlight -O ansi -l {} 2> /dev/null || cat {})) || ([ -d {} ] && ($_tree_cmd {}))) | head -200'"
export FZF_CTRL_R_OPT="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview '($_tree_cmd {}) | head -200'"

# fzf z binding
__my_fzf_z() {
  set -o nonomatch
  z -l 2>&1 | sed 's/^[0-9,.]* *//' \
    | fzf --height 40% -m --tac --reverse --preview '$_tree_cmd {} | head -200' \
    | while read item; do printf '%q ' "$item"; done
  echo
}

__my_fzf_z_widget() {
  LBUFFER="${LBUFFER}$(__my_fzf_z)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle -N __my_fzf_z_widget
bindkey '\C-j' __my_fzf_z_widget
# override the default fzf-cd-widget key binding
bindkey '\C-y' fzf-cd-widget

# _____________________ fzf and z _____________________

# --------------------- Config for local and remote machine ---------------------
if is_osx; then
  source $HOME/.zshrc.mac
elif is_linux; then
  source $HOME/.zshrc.linux
fi
# _____________________ Config for local and remote machine _____________________
