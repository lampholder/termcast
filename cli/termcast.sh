#!/bin/bash
set -e

uuid=`cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-f0-9' | head -c 32`

fifo="/tmp/termcast.fifo.$uuid"
tmux_config="/tmp/termcast.tmux_config.$uuid"
output="/tmp/termcast.output.$uuid"
tmux_socket="$uuid"

cat >$tmux_config <<EOL
unbind C-b
set -g prefix M-P # None for tmux >= 2.2

set-option -g status-left-length 70
set -g status-left '#(tail -n1 $output)'
set -g status-right ''
set -g status-interval 1
set -g default-terminal "screen-256color"
set-option -g status-position top
set-window-option -g window-status-current-format ''
set-window-option -g window-status-format ''
EOL

mkfifo $fifo
python stream.py $fifo > $output &
tmux -L $tmux_socket -2 -f $tmux_config new script -t0 -F $fifo

rm -rf $fifo
rm -rf $output
rm -rf $tmux_config
