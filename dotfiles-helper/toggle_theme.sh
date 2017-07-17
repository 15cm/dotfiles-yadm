#!/bin/bash
if [[ $ENV_THEME == 'light' ]]; then
  sed -i "1s/.*/export ENV_THEME='dark'/" ~/.zshrc.theme
else
  sed -i "1s/.*/export ENV_THEME='light'/" ~/.zshrc.theme
fi
tmux_run_in_all_panes () {
  tmux list-sessions -F '#{session_name}' | xargs -I SESS \
                                                  tmux list-windows -t SESS -F 'SESS:#{window_index}' | xargs -I SESS_WIN \
                                                                                                              tmux list-panes -t SESS_WIN -F 'SESS_WIN.#{pane_index}' | xargs -I SESS_WIN_PANE \
                                                                                                                                                                              tmux send-keys -t SESS_WIN_PANE "$1" Enter
}
tmux_run_in_all_panes 'exec $SHELL'
