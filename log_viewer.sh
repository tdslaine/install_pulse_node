#!/bin/bash

# Open three new terminal windows and execute the specified commands in each

# Open the first terminal window and execute the first command
gnome-terminal --tab --title="Execution Logs" -- bash -c "docker logs -f execution; exec bash"

# Open the second terminal window and execute the second command
gnome-terminal --tab --title="Beacon Logs" -- bash -c "docker logs -f beacon; exec bash"

# Open the third terminal window and execute the third command
gnome-terminal --tab --title="Validator Logs" -- bash -c "docker logs -f validator; exec bash"

# Open the fourth terminal window and execute htop
gnome-terminal --tab --title="HTOP" -- bash -c "htop; exec bash"

# Open the fifth terminal window and execute df -h
gnome-terminal --tab --title="DiskUsage" -- bash -c "watch df -H; exec bash"
