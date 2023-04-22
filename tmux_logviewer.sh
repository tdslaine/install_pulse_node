#!/bin/bash

# Create a new tmux session named 'logs' and run 'sudo docker logs -f execution' in it
tmux new-session -d -s logs 'sudo docker logs -f execution'

# Split the window horizontally and run 'sudo docker logs -f beacon'
tmux split-window -h -t logs 'sudo docker logs -f beacon'

# Select the first pane and split it vertically to run 'sudo docker logs -f validator'
tmux split-window -v -t logs:0.0 'sudo docker logs -f validator'

# Select the second pane (beacon) and split it vertically to run 'htop'
tmux split-window -v -t logs:0.1 'htop'

# Evenly distribute the pane sizes
tmux select-layout -t logs even-horizontal

# Create a new window with 'sudo watch df -H' running
tmux new-window -n "DiskUsage" -t logs:1 'sudo watch df -H'

# Attach to the tmux session
tmux attach-session -t logs:0.0

