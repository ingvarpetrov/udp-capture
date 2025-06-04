#!/bin/bash
set -e

echo "[entrypoint.sh] Args: $@"
echo "[entrypoint.sh] Listing /usr/local/bin:"
ls -l /usr/local/bin

if [ $# -gt 0 ]; then
  echo "[entrypoint.sh] Executing: $@"
  exec "$@"
else
  echo "[entrypoint.sh] No command provided, running tail."
  exec tail -f /dev/null
fi 