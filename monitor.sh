#!/bin/bash
set -e

CONTAINER_NAME=pu-capture

# Install tmux if not present
if ! command -v tmux &> /dev/null; then
  echo "tmux not found. Installing..."
  sudo apt-get update && sudo apt-get install -y tmux
fi

docker exec -it $CONTAINER_NAME tmux attach-session -t capture

# After tmux session ends, stop and remove the container if it is still running
if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "Stopping and removing Docker container: $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME
fi 