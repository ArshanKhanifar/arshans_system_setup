# This file is now used in byobu, previously it was my .tmux.conf, but now it's under byobu's
# keybindings.tmux file.
unbind-key -n C-b

# for all commands ctrl a is the prefix
set -g prefix C-Space
set -g prefix2 F12
bind C-Space send-prefix

# tmux panes 
# note: definition of "vertical" in tmux is the opposite of vim's
# and I'm using vim's.
unbind s
bind s split-window -v
unbind v
bind v split-window -h

# smart pane switching with awareness of vim splits
bind -n C-h if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-l" "select-pane -R"
bind -n C-\\ if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-\\" "select-pane -l"

