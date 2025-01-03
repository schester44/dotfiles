#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

session_icon=""

green="#5EFF78"
yellow="#FFC400"
light_yellow="#454A33"
bg="#172637"
fg="#9C9C9D"
white="#ffffff"

inactive_window_icon=" "
active_window_icon=" "
left_separator=""
right_separator=""

status_background_color=$bg

# remove administrative debris (session name, hostname, time) in status bar
# add icon when prefix is pressedbg
tmux set-option -g status-left "#{?client_prefix,#[bg=${green}]#[fg=${bg}] ${session_icon} , ${session_icon} }#[bg=${bg}]#[fg=${fg}] #S"

tmux set-option -g status-right ''
tmux set-option -g status-style "fg=${fg},bg=${bg}"
tmux set-option -g status-left-length 80
tmux set-option -g status-justify centre

tmux set-option -g pane-active-border-style "bg=default,fg=${fg}"
tmux set-option -g pane-border-style "bg=default,fg=colour245"
tmux set-option -g pane-border-lines "double"

tmux set-window-option -g window-status-activity-style "underscore,fg=#828bb8,bg=${bg}"
tmux set-window-option -g window-status-separator " "
tmux set-window-option -g window-status-current-format "#[fg=${status_background_color}]#[bg=${bg}]${left_separator:?}#[fg=${white}]#[bg=${status_background_color}] ${inactive_window_icon}#[fg=${yellow},bold,bg=${status_background_color}]#I:#W#[fg=${status_background_color}]#[bg=${bg}]${right_separator:?}#[none]"
