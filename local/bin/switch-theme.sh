#!/bin/bash

is_osx () {
  [[ $('uname') == 'Darwin' ]]
}

powerline_config_file="$HOME/.config/powerline/config.json"
powerline_tmux_binding="$HOME/.config/powerline/bindings/tmux/powerline.conf"
cur_theme=$(jq -r '.current_theme' "$powerline_config_file")
vimrc_theme_file="$HOME/.vimrc.theme"
alacritty_config_file="$HOME/.alacritty.yml"
ranger_scope_file="$HOME/.config/ranger/scope.sh"
leetcode_cli_config_file="$HOME/.lc/config.json"
glances_config_file="$HOME/.config/glances/glances.conf"

jq_tmp=$(mktemp)

if [[ $cur_theme == 'light' ]]; then
  # switch to dark color schemes
  jq '.current_theme = "dark" 
  | .ext.shell.colorscheme = "nord" 
  | .ext.tmux.colorscheme = "nord"' \
     $powerline_config_file > $jq_tmp && \
    mv $jq_tmp $powerline_config_file
  sed --follow-symlinks -i 's/\(set background=\).*/\1dark/' $vimrc_theme_file
  sed --follow-symlinks -i 's/\(colorscheme \).*/\1Tomorrow-Night/' $vimrc_theme_file
  sed --follow-symlinks -i 's/\(colors: \*color_scheme_\).*/\1dark/' $alacritty_config_file
  sed --follow-symlinks -i 's/\(HIGHLIGHT_STYLE=\).*/\1"Moria"/' $ranger_scope_file
  sed --follow-symlinks -i 's/\(curse_theme=\).*/\1black/' $glances_config_file
  jq '.color.theme = "dark"' $leetcode_cli_config_file > $jq_tmp && \
    mv $jq_tmp $leetcode_cli_config_file
  guake --change-palette 'Tomorrow Night'
else
  # switch to light color schemes
  jq '.current_theme = "light" 
  | .ext.shell.colorscheme = "solarized-light" 
  | .ext.tmux.colorscheme = "solarized-light"' \
     $powerline_config_file  > $jq_tmp && mv $jq_tmp $powerline_config_file
  sed --follow-symlinks -i 's/\(set background=\).*/\1light/' $vimrc_theme_file
  sed --follow-symlinks -i 's/\(colorscheme \).*/\1solarized/' $vimrc_theme_file
  sed --follow-symlinks -i 's/\(colors: \*color_scheme_\).*/\1light/' $alacritty_config_file
  sed --follow-symlinks -i 's/\(HIGHLIGHT_STYLE=\).*/\1"Zellner"/' $ranger_scope_file
  sed --follow-symlinks -i 's/\(curse_theme=\).*/\1white/' $glances_config_file
  jq '.color.theme = "solarized.light"' $leetcode_cli_config_file > $jq_tmp && \
    mv $jq_tmp $leetcode_cli_config_file
  guake --change-palette 'Solarized Light'
fi

powerline-daemon --replace
tmux source "$powerline_tmux_binding"
