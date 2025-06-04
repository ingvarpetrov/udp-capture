#!/bin/bash
set -e

CONTAINER_NAME=pu-capture
USER_ID=$(id -u)
GROUP_ID=$(id -g)
PROJECT_DIR=$(pwd)

# Clear the output directory
if [ -d "$PROJECT_DIR/output" ]; then
  rm -f "$PROJECT_DIR/output"/*
fi

# Stop and remove any existing container with the same name
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  docker rm -f $CONTAINER_NAME
fi

# Start container if not running
docker run -d \
  --name $CONTAINER_NAME \
  --network host \
  --privileged \
  -u $USER_ID:$GROUP_ID \
  -e USER_ID=$USER_ID \
  -e GROUP_ID=$GROUP_ID \
  -v "$PROJECT_DIR/src":/src \
  -v "$PROJECT_DIR/output":/output \
  -v "$PROJECT_DIR/capture.cfg":/app/capture.cfg \
  tsduck-capture
# Always (re)start tmux capture session
if docker exec $CONTAINER_NAME tmux has-session -t capture 2>/dev/null; then
  docker exec $CONTAINER_NAME tmux kill-session -t capture
fi
docker exec -it $CONTAINER_NAME tmux new-session -d -s capture '/src/capture.sh' 