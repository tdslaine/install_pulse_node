#!/bin/bash

# Kill prev. sessions
tmux kill-session -t logs

# Create a new tmux session named 'logs'
tmux new-session -d -s logs

# Split the window horizontally
tmux split-window -h -t logs

# Select the first pane and split it vertically
tmux split-window -v -t logs:0.0

# Select the second pane and split it vertically
tmux split-window -v -t logs:0.1

# Evenly distribute the pane sizes
tmux select-layout -t logs tiled

# Send the commands to the respective panes
tmux send-keys -t logs:0.0 'docker logs -f --tail=30 execution' Enter
tmux send-keys -t logs:0.1 'docker logs -f --tail=30 validator' Enter
tmux send-keys -t logs:0.2 'docker logs -f --tail=30 beacon' Enter
tmux send-keys -t logs:0.3 'htop' Enter

# Create a new window with 'sudo watch df -H' running
tmux new-window -n "DiskUsage" -t logs:1 'watch df -H'

# Select the first pane (0.0)
tmux select-pane -t logs:0.0

# Attach to the tmux session
tmux attach-session -t logs:0.0
