#!/bin/bash

# Close any existing terminal windows with the specified titles
wmctrl -l | grep -w "Execution Logs\|Beacon Logs\|Validator Logs\|HTOP\|DiskUsage" | awk '{print $1}' | xargs -r wmctrl -ic

# Wait for a moment to ensure the previous terminal windows are closed
sleep 2

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
