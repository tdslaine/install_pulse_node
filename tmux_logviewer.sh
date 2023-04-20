#!/bin/bash

# Create a new tmux session named 'logs' and run 'sudo docker logs -f execution' in it
tmux new-session -d -s logs -n "Logs" 'sudo docker logs -f execution'

# Split the window horizontally and run 'sudo docker logs -f beacon'
tmux split-window -h -t logs:0.0 'sudo docker logs -f beacon'

# Select the first pane and split it vertically to run 'sudo docker logs -f validator'
tmux split-window -v -t logs:0.0 'sudo docker logs -f validator'

# Create a new window with 'htop' running
tmux new-window -n "HTOP" -t logs:1 'htop'

# Create another new window with 'sudo watch df -H' running
tmux new-window -n "DiskUsage" -t logs:2 'sudo watch df -H'

# Attach to the tmux session
tmux attach-session -t logs
