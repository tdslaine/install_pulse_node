#!/bin/bash

# Close any existing terminal windows with the specified titles
wmctrl -l | grep -w "Execution Logs\|Beacon Logs\|Validator Logs\|HTOP\|DiskUsage" | awk '{print $1}' | xargs -r wmctrl -ic >/dev/null 2>&1

# Wait for a moment to ensure the previous terminal windows are closed
sleep 2

# Open new terminal windows and execute the specified commands in each

gnome-terminal --tab --title="Execution Logs" -- bash -c "docker logs -f --tail=20 execution; exec bash"

gnome-terminal --tab --title="Beacon Logs" -- bash -c "docker logs -f --tail=20 beacon; exec bash"

gnome-terminal --tab --title="Validator Logs" -- bash -c "docker logs -f --tail=20 validator; exec bash"

gnome-terminal --tab --title="HTOP" -- bash -c "htop; exec bash"

gnome-terminal --tab --title="DiskUsage" -- bash -c "watch df -H; exec bash"

gnome-terminal --tab --title="Docker Status" -- bash -c "watch docker ps; exec bash"
