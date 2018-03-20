# zmodload zsh/zprof
# _____________________ profiling _____________________

# --------------------- Common Config  ---------------------
# Fix for emacs tramp mode
# [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Disable updates
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
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
ZSH_TMUX_AUTOSTART_ONCE=true

# nvm(loaded with zsh-nvm plugin)
export NVM_DIR="$HOME/.nvm"
if [[ $TERM == "dumb" ]]; then
  export NVM_LAZY_LOAD=true
fi
# _____________________ ENV _____________________

# --------------------- PATH ---------------------
export PATH="/usr/local/bin:$HOME/local/bin:$PATH"
# Path for powerline on mac
export PATH="$PATH:$HOME/Library/Python/2.7/bin"
# Path for go
export PATH="$PATH:$HOME/go/bin"
# _____________________ PATH _____________________

# --------------------- Plugins ---------------------
# Env
ZSH_AUTOSUGGEST_USE_ASYNC=true

plugins=(git tmux z zsh-autosuggestions zsh-syntax-highlighting zsh-nvm cd-gitroot zce yadm docker)
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

# --------------------- Version Management ---------------------

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# pyenv-virtualenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# jenv(lazy load)
export PATH="$HOME/.jenv/bin:$PATH"
# if which jenv > /dev/null; then eval "$(jenv init -)"; fi
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

# _____________________ Version Management _____________________

# --------------------- exa ---------------------
if which exa > /dev/null; then
  _ls_cmd="exa --color always --group-directories-first --sort extension"
  alias ls2="$_ls_cmd"
  alias ls="$_ls_cmd --git-ignore"
  alias la="$_ls_cmd -al --git"
  alias ll="$_ls_cmd -l --git --git-ignore"
  alias l="$_ls_cmd -l --git --git-ignore"
  alias tree="$_ls_cmd --tree --level 2 -l --git"
  alias tree2="$_ls_cmd --tree"
  _tree_cmd="$_ls_cmd --tree --level 2"
else
  _ls_cmd="ls --color=tty --group-directories-first"
  alias ls="$_ls_cmd"
  alias ll="$_ls_cmd -lh"
  alias l="$_ls_cmd -lh"
  alias la="$_ls_cmd -lAh"
  _tree_cmd="tree -C"
fi
# _____________________ exa _____________________

# --------------------- fzf ---------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_TMUX=0
export FZF_DEFAULT_COMMAND="fd --type f --follow --exclude '.git' "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS="--height 40% -m --reverse --bind 'ctrl-d:page-down,ctrl-u:page-up,ctrl-k:kill-line,pgup:preview-page-up,pgdn:preview-page-down,alt-a:toggle-all'"
export FZF_CTRL_T_OPTS="--preview '(([ -f {} ] && (highlight -O ansi -l {} 2> /dev/null || cat {})) || ([ -d {} ] && $_tree_cmd {} )) | head -200'"
export FZF_CTRL_R_OPT=" --exact --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview '$_tree_cmd {} | head -200'"
export FZF_COMPLETION_OPTS=$FZF_CTRL_T_OPTS

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --no-ignore --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --no-ignore --follow --exclude ".git" . "$1"
}

# fzf z binding
__fzf_z() {
  z -l | sed 's/^[0-9,.]* *//' \
    | fzf --tac --reverse --preview "$_tree_cmd {} | head -200" --preview-window right:30%
}

__fzf_z_arg() {
  __fzf_z | while read item; do printf ' %q/' "$item"; done
  echo
}

__fzf_z_arg_widget() {
  LBUFFER="${LBUFFER}$(__fzf_z_arg)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle -N __fzf_z_arg_widget

# fzf z arg
bindkey '^[j' __fzf_z_arg_widget

__fzf_z_cd_widget() {
  local dir=$(__fzf_z)
  cd "$dir"
  local ret=$?
  zle fzf-redraw-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle -N __fzf_z_cd_widget

# fzf z cd
bindkey '^j' __fzf_z_cd_widget

# fzf dirs under current dir
__fzf_dir() {
  set -o nonomatch
  _fzf_compgen_dir . \
    | fzf --tac --reverse --preview "$_tree_cmd {} | head -200" \
    | while read item; do printf ' %q/' "$item"; done
  echo
}

__fzf_dir_widget() {
  LBUFFER="${LBUFFER}$(__fzf_dir)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle -N __fzf_dir_widget

bindkey '^x' fzf-cd-widget
# alt-t
bindkey '^[x' __fzf_dir_widget

export FZF_COMPLETION_TRIGGER=':'

# _____________________ fzf and z _____________________


# --------------------- Config for local and remote machine ---------------------
if is_osx; then
  source $HOME/.zshrc.mac
else
  source $HOME/.zshrc.linux
fi
# _____________________ Config for local and remote machine _____________________

# --------------------- Common Alias ---------------------
alias rz='exec $SHELL'
alias vi="vim"
alias st="switch-theme.sh"
alias gcmsg!="git commit --allow-empty-message -m ''"
alias ew="emacsclient -s misc -t"
alias more="more -R"
alias ccat="ccat -C always"
alias cg="cd-gitroot"
alias op="open"
alias prl="parallel"
# _____________________ Common Alias  _____________________

# --------------------- Function Alias ---------------------
rp() {
  realpath $1 | clip
}

# _____________________ Function Alias _____________________

# --------------------- profiling ---------------------
# zprof
