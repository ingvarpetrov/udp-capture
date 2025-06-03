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
cat <<EOF
==============================================
Installation complete!

Next steps:
1. Test a stream:             ./test.sh <your-udp-address>   # e.g. ./test.sh 239.0.0.1:1234
   (Use your own UDP address to verify you can receive data before editing the config)
2. Edit the configuration file: capture.cfg
3. Start the capture process: ./run.sh
4. Monitor the session:       ./monitor.sh

You are now in the udp-capture-main directory.
==============================================
EOF 