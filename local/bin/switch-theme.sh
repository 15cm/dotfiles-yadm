#!/bin/bash

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

cmd_exists () {
  command -v $1 > /dev/null
}

if ! cmd_exists jq; then
  echo "jq not found!"
  exit 1
fi

# Get $GLOBAL_THEME
source ~/.global-env.sh

powerline_config_file="$HOME/.config/powerline/config.json"
powerline_tmux_binding="$HOME/.config/powerline/bindings/tmux/powerline.conf"
vimrc_theme_file="$HOME/.vimrc.theme"
alacritty_config_file="$HOME/.alacritty.yml"
ranger_config_file="$HOME/.config/ranger/rc.conf"
ranger_scope_file="$HOME/.config/ranger/scope.sh"
leetcode_cli_config_file="$HOME/.lc/config.json"
glances_config_file="$HOME/.config/glances/glances.conf"
emacs_server_dir="/tmp/emacs$UID"

jq_tmp=$(mktemp)

# Async
if [[ $GLOBAL_THEME == 'light' ]]; then
  # Switch to dark color schemes

  # Powerline
  jq '.ext.shell.colorscheme = "nord" 
  | .ext.tmux.colorscheme = "nord"' \
     $powerline_config_file > $jq_tmp && \
    mv $jq_tmp $powerline_config_file

  # Emacs
  if cmd_exists emacsclient; then
    for p in ${emacs_server_dir}/*; do
      f=$(basename $p)
      emacsclient -s $f -eun '(load "~/.config/scripts/emacs/load-theme-dark.el")'
    done
  fi
else
  # Switch to light color schemes

  # Powerline
  jq '.ext.shell.colorscheme = "solarized-light" 
  | .ext.tmux.colorscheme = "solarized-light"' \
     $powerline_config_file  > $jq_tmp && mv $jq_tmp $powerline_config_file

  # Emacs
  if cmd_exists emacsclient; then
    for p in ${emacs_server_dir}/*; do
      f=$(basename $p)
      emacsclient -s $f -eun '(load "~/.config/scripts/emacs/load-theme-light.el")'
    done
  fi
fi

cmd_exists powerline-daemon && powerline-daemon --replace &
cmd_exists tmux && tmux source "$powerline_tmux_binding" &

# Sync
if [[ $GLOBAL_THEME == 'light' ]]; then
  # Switch to dark color schemes

  # vim
  sed --follow-symlinks -i 's/\(set background=\).*/\1dark/
  s/\(colorscheme \).*/\1Tomorrow-Night/' $vimrc_theme_file

  # Alacritty
  sed --follow-symlinks -i 's/\(colors: \*color_scheme_\).*/\1dark/' $alacritty_config_file

  # Ranger
  sed --follow-symlinks -i 's/\(set colorscheme\).*/\1 custom-dark/' $ranger_config_file
  sed --follow-symlinks -i 's/\(HIGHLIGHT_STYLE=\).*/\1"moria"/' $ranger_scope_file

  # Glances
  sed --follow-symlinks -i 's/\(curse_theme=\).*/\1black/' $glances_config_file

  # Leetcode-cli
  jq '.color.theme = "dark"' $leetcode_cli_config_file > $jq_tmp && \
    mv $jq_tmp $leetcode_cli_config_file

  # Guake
  cmd_exists guake && guake --change-palette 'Tomorrow Night'

  # Global
  sed -i 's/\(GLOBAL_THEME=\).*/\1dark/' ~/.global-env.sh
else
  # vim
  sed --follow-symlinks -i 's/\(set background=\).*/\1light/
      s/\(colorscheme \).*/\1solarized/' $vimrc_theme_file

  # Alacritty
  sed --follow-symlinks -i 's/\(colors: \*color_scheme_\).*/\1light/' $alacritty_config_file

  # Ranger
  sed --follow-symlinks -i 's/\(set colorscheme\).*/\1 custom-light/' $ranger_config_file
  sed --follow-symlinks -i 's/\(HIGHLIGHT_STYLE=\).*/\1"solarized-light"/' $ranger_scope_file

  # Glances
  sed --follow-symlinks -i 's/\(curse_theme=\).*/\1white/' $glances_config_file

  # Leetcode-cli
  jq '.color.theme = "solarized.light"' $leetcode_cli_config_file > $jq_tmp && \
    mv $jq_tmp $leetcode_cli_config_file

  # Guake
  cmd_exists guake && guake --change-palette 'Solarized Light'

  # Global
  sed -i 's/\(GLOBAL_THEME=\).*/\1light/' ~/.global-env.sh
fi
