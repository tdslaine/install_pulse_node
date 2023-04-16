#!/bin/bash

gnome-terminal --tab --title="Execution Logs" -- bash -c 'sudo docker logs -f execution' \
               --tab --title="Beacon Logs" -- bash -c 'sudo docker logs -f beacon' \
               --tab --title="Validator Logs" -- bash -c 'sudo docker logs -f validator' \
               --tab --title="HTOP" -- bash -c 'htop' \
               --tab --title="DiskUsage" -- bash -c 'sudo watch df -H'
