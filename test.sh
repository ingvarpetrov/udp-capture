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
DOCKER_CMD=(docker run --rm \
  -v "$PROJECT_DIR":/data \
  --network host \
  tsduck-capture)

TSP_CMD=(tsp)
if [ -n "$INTERFACE_IP" ]; then
  TSP_CMD+=( -I ip "$UDP_ADDR" --local-address "$INTERFACE_IP" -O file "/data/$TMPFILE" --max-duration 5 )
else
  TSP_CMD+=( -I ip "$UDP_ADDR" -O file "/data/$TMPFILE" --max-duration 5 )
fi

echo "Testing capture from $UDP_ADDR using Docker..."
"${DOCKER_CMD[@]}" "${TSP_CMD[@]}"

if [ -s "$TMPFILE" ]; then
  echo "SUCCESS: Data captured from $UDP_ADDR ($TMPFILE, $(du -h "$TMPFILE" | cut -f1))"
  rm "$TMPFILE"
  exit 0
else
  echo "FAIL: No data captured from $UDP_ADDR"
  rm -f "$TMPFILE"
  exit 2
fi 