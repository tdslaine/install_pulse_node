#!/bin/bash

# Open three new terminal windows and execute the specified commands in each

# Open the first terminal window and execute the first command
gnome-terminal --tab --title="Execution Logs" --command="bash -c 'docker logs -f execution'"

# Open the second terminal window and execute the second command
gnome-terminal --tab --title="Beacon Logs" --command="bash -c 'docker logs -f beacon'"

# Open the third terminal window and execute the third command
gnome-terminal --tab --title="Validator Logs" --command="bash -c 'docker logs -f validator'"

# Open the fourth terminal window and execute htop
gnome-terminal --tab --title="HTOP" --command="bash -c 'htop'"

# Open the fifth terminal window and execute df -h
gnome-terminal --tab --title="DiskUsage" --command="bash -c 'watch df -H'"
