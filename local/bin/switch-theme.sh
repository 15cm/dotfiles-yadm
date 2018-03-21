#!/bin/bash

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

powerline_config_file="$HOME/.config/powerline/config.json"
cur_theme=$(jq -r '.current_theme' "$powerline_config_file")
jq_tmp=$(mktemp)
if [[ $cur_theme == 'light' ]]; then
  jq '.current_theme = "dark" 
  | .ext.shell.colorscheme = "nord" 
  | .ext.tmux.colorscheme = "nord"' \
     $powerline_config_file > $jq_tmp && mv $jq_tmp $powerline_config_file
  sed -i 's/\(set background=\).*/\1dark/' ~/.vimrc.theme
  sed -i 's/\(colors: \*color_scheme_\).*/\1dark/' ~/.alacritty.yml
  # highlight for ranger
  sed -i 's/\(HIGHLIGHT_STYLE=\).*/\1"Moria"/' ~/.config/ranger/scope.sh

else
  # switch to light color schemes
  jq '.current_theme = "light" 
  | .ext.shell.colorscheme = "solarized-light" 
  | .ext.tmux.colorscheme = "solarized-light"' \
     $powerline_config_file  > $jq_tmp && mv $jq_tmp $powerline_config_file
  sed -i 's/\(set background=\).*/\1light/' ~/.vimrc.theme
  sed -i 's/\(colors: \*color_scheme_\).*/\1light/' ~/.alacritty.yml
  sed -i 's/\(HIGHLIGHT_STYLE=\).*/\1"Zellner"/' ~/.config/ranger/scope.sh
fi

powerline-daemon --replace
if is_osx; then
  tmux source ~/.tmux.conf.mac
else
  tmux source ~/.tmux.conf.linux
fi
