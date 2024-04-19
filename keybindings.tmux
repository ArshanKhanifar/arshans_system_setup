# This file is now used in byobu, previously it was my .tmux.conf, but now it's under byobu's
# keybindings.tmux file.
unbind-key -n C-a

# for all commands ctrl a is the prefix
set -g prefix ^A
set -g prefix2 F12
bind a send-prefix

# prefix + s gives you split window capability
unbind s
bind s split-window -h
unbind v
bind v split-window -v

# smart pane switching with awareness of vim splits
bind -n C-h if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-l" "select-pane -R"
bind -n C-\\ if-shell "$(tmux display-message -p '#{pane_current_command}' | grep -iq vim)" "send-keys C-\\" "select-pane -l"

