#!/bin/bash
set -e

CONTAINER_NAME=tsduck-capture

# Install tmux if not present
if ! command -v tmux &> /dev/null; then
  echo "tmux not found. Installing..."
  sudo apt-get update && sudo apt-get install -y tmux
fi

docker exec -it $CONTAINER_NAME tmux attach-session -t capture 