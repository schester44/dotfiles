#!/usr/bin/env bash

session_icon=""

green="#5EFF78"
light_yellow="#FFEE80"
cobalt_bg="#162D40"
fg="#9C9C9D"

active_window_icon=" "
left_separator=""
right_separator=""

status_background_color=$light_yellow
bg="default"

# add icon when prefix is pressedbg
tmux set-option -g status-left "#{?client_prefix,#[bg=${green}]#[fg=${bg}] ${session_icon} , ${session_icon} }#[bg=${bg}]#[fg=${fg}] #S"

tmux set-option -g status-right ''
tmux set-option -g status-style "fg=${fg},bg=${bg}"
tmux set-option -g status-left-length 80
tmux set-option -g status-justify centre

tmux set-option -g pane-active-border-style "bg=${bg},fg=${green}"
tmux set-option -g pane-border-style "bg=${bg},fg=#15232D"
tmux set-option -g pane-border-lines "double"

tmux set-window-option -g window-status-activity-style "underscore,fg=#828bb8,bg=${bg}"
tmux set-window-option -g window-status-separator " "
tmux set-window-option -g window-status-current-format "#[fg=${status_background_color}]#[bg=${bg}]${left_separator:?}#[fg=${cobalt_bg}]#[bg=${status_background_color}]${active_window_icon}#[fg=${cobalt_bg},bg=${status_background_color}]#W#[fg=${status_background_color}]#[bg=${bg}]${right_separator:?}#[none]"
