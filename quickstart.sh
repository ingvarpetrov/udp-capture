#!/bin/bash
set -e

# Download and extract the latest udp-capture repo tarball
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
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
1. Edit the configuration file: capture.cfg
2. Start the capture process: ./run.sh
3. Monitor the session:       ./monitor.sh
4. Test a stream:             ./test.sh 239.0.0.1:1234

You are now in the udp-capture-main directory.
==============================================
EOF 