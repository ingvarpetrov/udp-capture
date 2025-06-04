#!/bin/bash
set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <udp_address> (e.g. 239.0.0.1:1234)"
  exit 1
fi

UDP_ADDR="$1"
CONFIG_FILE="capture.cfg"
INTERFACE_IP=""

# Parse interface_ip from config if set
while IFS= read -r line; do
  if [[ "$line" =~ ^interface_ip= ]]; then
    INTERFACE_IP="${line#interface_ip=}"
  fi
done < "$CONFIG_FILE"

TMPFILE="test_capture_$$.ts"
PROJECT_DIR=$(pwd)

# Build the docker run command (no -u, let entrypoint handle user/group)
DOCKER_CMD=(docker run --rm --init \
  -v "$PROJECT_DIR":/data \
  --network host \
  pu-capture)

PU_CMD=(/usr/local/bin/__pu "$UDP_ADDR")
if [ -n "$INTERFACE_IP" ]; then
  PU_CMD+=(-ii "$INTERFACE_IP")
fi
PU_CMD+=(-o "/data/$TMPFILE" -t "$DURATION")

# Use timeout with --foreground if available
if timeout --help 2>&1 | grep -q -- '--foreground'; then
  TIMEOUT_CMD=(timeout --foreground 7)
else
  TIMEOUT_CMD=(timeout 7)
fi

echo "Testing capture from $UDP_ADDR using Docker..."
echo "In the next few seconds, the script will try to connect to the multicast group and see if it can read data from it. Please hold on..."
"${TIMEOUT_CMD[@]}" "${DOCKER_CMD[@]}" "${PU_CMD[@]}"

# Wait a moment to ensure file is written
sleep 1

if [ -s "$TMPFILE" ]; then
  echo "SUCCESS: Data captured from $UDP_ADDR ($TMPFILE, $(du -h "$TMPFILE" | cut -f1))"
  rm -f "$TMPFILE"
  exit 0
else
  echo "FAIL: No data captured from $UDP_ADDR"
  rm -f "$TMPFILE"
  exit 2
fi 