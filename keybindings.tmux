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

# Resize panes with prefix + option + jklh
# Note: by default I've set Option + Left & Option + Right on iterm to send some other pattern.
# That's because I like to hold option & jump between words. That's why resize-pane won't work.
bind-key -r -T prefix       M-Up              resize-pane -U 2
bind-key -r -T prefix       M-Down            resize-pane -D 2
bind-key -r -T prefix       M-Left            resize-pane -L 5 # wont work in iterm
bind-key -r -T prefix       M-Right           resize-pane -R 5 # wont work in iterm

# Resize panes with prefix + option + jklh
bind-key -r -T prefix       M-k               resize-pane -U 2
bind-key -r -T prefix       M-j               resize-pane -D 2
bind-key -r -T prefix       M-h               resize-pane -L 5
bind-key -r -T prefix       M-l               resize-pane -R 5

# mouse tracking (doesn't work nicely in iterm2)
# set-option -g mouse on

