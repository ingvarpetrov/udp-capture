#!/bin/bash
set -e

if [ $# -gt 0 ]; then
  exec "$@"
else
  exec tail -f /dev/null
fi 