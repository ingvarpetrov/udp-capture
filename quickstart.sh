#!/bin/bash
set -e

# Download and extract the latest udp-capture repo tarball into the current directory
if [ -d udp-capture-main ]; then
  echo "Removing existing udp-capture-main directory..."
  rm -rf udp-capture-main
fi

echo "Downloading udp-capture project..."
curl -L https://github.com/ingvarpetrov/udp-capture/archive/refs/heads/main.tar.gz | tar xz

cd udp-capture-main

echo "Building Docker image (this may take a few minutes)..."
./install.sh

echo
cat <<'EOF'

============================================================
 UDP Mass Capture System - Installation Complete
============================================================


echo -e "\033[1mNext steps:\033[0m"

  1. \033[32mTest a stream\033[0m:
     ./test.sh <your-udp-address>   # e.g. ./test.sh 239.0.0.1:1234
     (Use your own UDP address to verify you can receive data before editing the config)

  2. \033[32mEdit the configuration file\033[0m:
     capture.cfg

  3. \033[32mStart the capture process\033[0m:
     ./run.sh

  4. \033[32mMonitor the session\033[0m:
     ./monitor.sh

\033[36mYou are now in the udp-capture-main directory.\033[0m
============================================================
EOF 