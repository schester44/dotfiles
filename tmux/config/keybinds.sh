##!/usr/bin/env bash

# reload tmux config with C-a r
tmux unbind r
tmux bind-key r source-file ~/.tmux.conf \; display-message "Config reloaded..."

# Change prefix to C-a
tmux unbind C-b
tmux set-option -g prefix C-a
tmux bind-key C-a send-prefix

# tmux session selector
# https://github.com/joshmedeski/sesh
# This key is mapped to cmd+k via Wezterm


# split panes using | and -
tmux bind-key | split-window -h -c "#{pane_current_path}"
tmux bind-key - split-window -v -c "#{pane_current_path}"
tmux unbind '"'
tmux unbind %

# Automatically set the default-path to the current pane's working directory when creating a new window
tmux bind-key c new-window -c "#{pane_current_path}"

# Resize panes with prefix-HJKL.
tmux bind-key -r -T prefix J resize-pane -D 3
tmux bind-key -r -T prefix K resize-pane -U 3
tmux bind-key -r -T prefix H resize-pane -L 3
tmux bind-key -r -T prefix L resize-pane -R 3

# switch panes with prefix-hjkl
tmux bind-key h select-pane -L
tmux bind-key l select-pane -R
tmux bind-key j select-pane -D
tmux bind-key k select-pane -U

