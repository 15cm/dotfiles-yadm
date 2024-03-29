# zmodload zsh/zprof
# _____________________ profiling _____________________


# --------------------- Common Config ---------------------
# Fix for emacs tramp mode
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Disable updates
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
# Disable Ctrl-s which freezes the terminal
stty -ixon

# _____________________ Common Config _____________________

# --------------------- Helpers ---------------------
sys_name=$(uname -s)

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
export EDITOR=vim
export _Z_DATA="$HOME/.z/.z"
. ~/.z/z.sh

# GPG Fix
export GPG_TTY=$(tty)

# tldr color for light/dark themes
export TLDR_COLOR_BLANK="blue"
export TLDR_COLOR_DESCRIPTION="green"
export TLDR_COLOR_PARAMETER="blue"

# _____________________ ENV _____________________

# --------------------- Plugins ---------------------
# Auto suggestions
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Alias tips
export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="_ ll vi"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting cd-gitroot zce yadm docker alias-tips)
# _____________________ Plugins _____________________

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# --------------------- Completions ---------------------
fpath=($HOME/.zsh-completions $fpath)
# _____________________ Completions _____________________

# --------------------- Key map ---------------------
export KEYTIMEOUT=5

# Fix backspace behavior after switching back from command mode
# https://unix.stackexchange.com/questions/290392/backspace-in-zsh-stuck
bindkey -v '^?' backward-delete-char

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
bindkey -a '^[v' edit-command-line # equivalent to 'bindkey -M vicmd'
bindkey '^[v' edit-command-line

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

# ranger
# Automatically change the directory in zsh after closing ranger
ranger-cd() {
  tempfile="$(mktemp -t tmp.XXXXXX)"
  ranger --choosedir="$tempfile" "${@:-$(pwd)}"
  test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
      cd -- "$(cat "$tempfile")"
    fi
  rm -f -- "$tempfile"
}

bindkey -s '^u' 'ranger .^m'
bindkey -s '^[u' 'ranger-cd^m'

# _____________________ Key map _____________________

# --------------------- Version Management ---------------------

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then eval "$(pyenv init - --no-rehash)"; fi

# pyenv-virtualenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# nvm
export NVM_DIR="$HOME/.nvm"
function load_nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

# Disable lazy load in emacs
if [ -z $INSIDE_EMACS ]; then
  lazy_load load_nvm nvm npm node leetcode hexo web-ext
else
  load_nvm
fi

# [ -z "$INSIDE_EMACS" ] || (load_nvm; export NVM)

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
lazy_load load_rbenv rbenv ruby gem pry

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
  alias ls="$_ls_cmd"
  alias la="$_ls_cmd -al --git"
  alias ll="$_ls_cmd -l --git"
  alias l="$_ls_cmd -l --git"
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

_gen_fzf_default_opts() {
  local base03="234"
  local base02="235"
  local base01="240"
  local base00="241"
  local base0="244"
  local base1="245"
  local base2="252"
  local base3="230"
  local yellow="136"
  local orange="166"
  local red="160"
  local magenta="125"
  local violet="61"
  local blue="33"
  local cyan="39"
  local green="64"

  # Solarized color scheme for fzf
  local FZF_COLOR_OPTS="--color fg:-1,bg:-1,hl:$magenta,fg+:$base02,bg+:$base2,hl+:$cyan
   --color info:$yellow,prompt:$yellow,pointer:$base3,marker:$base3,spinner:$yellow"
  export FZF_DEFAULT_OPTS="${FZF_COLOR_OPTS} --height 40% -m --reverse --bind 'ctrl-d:page-down,ctrl-u:page-up,ctrl-k:kill-line,pgup:preview-page-up,pgdn:preview-page-down,alt-a:toggle-all'"
}
_gen_fzf_default_opts

FD_DEFAULT_COMMAND="fd -H --no-ignore-vcs"
export FZF_TMUX=0
export FZF_DEFAULT_COMMAND="$FD_DEFAULT_COMMAND"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -t d"

export FZF_CTRL_T_OPTS="--preview '(([ -f {} ] && (highlight -O ansi -l {} 2> /dev/null || cat {})) || ([ -d {} ] && $_tree_cmd {} )) | head -200'"
export FZF_CTRL_R_OPT=" --exact --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview '$_tree_cmd {} | head -200'"
export FZF_COMPLETION_OPTS=$FZF_CTRL_T_OPTS

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd -H --no-ignore-vcs -t d $1
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

# --------------------- Config for different OS ---------------------
if [[ $sys_name = "Darwin" ]]; then
  source $HOME/.zshrc.mac
else
  source $HOME/.zshrc.linux
fi

# _____________________ Config for different OS _____________________

# --------------------- Powerline ---------------------
. $HOME/.config/powerline/bindings/zsh/powerline.zsh
# _____________________ Powerline _____________________

# --------------------- Common Alias ---------------------
alias rz='exec $SHELL'
alias vi="vim"
alias st="switch-theme.sh"
alias gcmsg!="git commit -m 'just a commit'"
alias ew="emacsclient -s misc -t -a vim"
alias more="more -R"
alias ccat="ccat -C always"
alias cdg="cd-gitroot"
alias prl="parallel"
alias grep="grep --color=auto"
alias rp="realpath"
alias sudo="sudo "
alias ssh="ssh -F ~/.ssh/interactive.conf"

# Leetcode
alias lc="leetcode"
alias lcsh="leetcode show"
alias lcsb="leetcode submit"
alias lct="leetcode test"
alias lcl="leetcode list"

# Tmux

alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'

# SSH
alias sshfs='sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3' # Prevent sshfs freeze the OS

# _____________________ Common Alias _____________________

# --------------------- profiling ---------------------
# zprof
