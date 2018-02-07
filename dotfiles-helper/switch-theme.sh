#!/bin/bash
powerline_config_file="$HOME/.config/powerline/config.json"
cur_theme=$(jq -r '.current_theme' "$powerline_config_file")
jq_tmp=$(mktemp)
if [[ $cur_theme == 'light' ]]; then
  jq '.current_theme = "dark" 
  | .ext.shell.colorscheme = "nord" 
  | .ext.tmux.colorscheme = "nord"' \
     $powerline_config_file > $jq_tmp && mv $jq_tmp $powerline_config_file
  sed -i 's/set background=\w*/set background=dark/' ~/.vimrc.theme
  sed -i 's/colors: \*color_scheme_\w*/colors: *color_scheme_dark/' ~/.alacritty.yml
else
  jq '.current_theme = "light" 
  | .ext.shell.colorscheme = "solarized-light" 
  | .ext.tmux.colorscheme = "solarized-light"' \
     $powerline_config_file  > $jq_tmp && mv $jq_tmp $powerline_config_file
  sed -i 's/set background=\w*/set background=light/' ~/.vimrc.theme
  sed -i 's/colors: \*color_scheme_\w*/colors: *color_scheme_light/' ~/.alacritty.yml
fi
powerline-daemon --replace
tmux source ~/.tmux.conf
