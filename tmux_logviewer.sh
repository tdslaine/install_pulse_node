#!/bin/bash

# Create a new tmux session named 'logs' and run 'sudo docker logs -f execution' in it
tmux new-session -d -s logs 'sudo docker logs -f execution'

# Split the window vertically and run 'sudo docker logs -f beacon'
tmux split-window -v -t logs 'sudo docker logs -f beacon'

# Select the first pane and split it horizontally to run 'sudo docker logs -f validator'
tmux split-window -h -t logs:0.0 'sudo docker logs -f validator'

# Select the second pane (beacon) and split it horizontally to run 'htop'
tmux split-window -h -t logs:0.1 'htop'

# Evenly distribute the pane sizes
tmux select-layout -t logs even-horizontal

# Create a new window with 'sudo watch df -H' running
tmux new-window -n "DiskUsage" -t logs:1 'sudo watch df -H'

# Select the first pane (0.0)
tmux select-pane -t logs:0.0

# Attach to the tmux session
tmux attach-session -t logs
