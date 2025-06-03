#!/bin/bash
set -e

# Download and extract the latest udp-capture repo tarball into the current directory
if [ -d udp-capture-main ]; then
  echo "Removing existing udp-capture-main directory..."
  rm -rf udp-capture-main
fi

echo "Downloading udp-capture project..."
curl -L https://github.com/ingvarpetrov/udp-capture/archive/refs/heads/main.tar.gz | tar xz

cd udp-capture-main/src

# Check for Docker
if ! command -v docker &> /dev/null; then
  echo "ERROR: Docker is not installed or not in your PATH."
  echo "Please see the Docker installation instructions in the README:"
  echo "https://github.com/ingvarpetrov/udp-capture#docker-installation-ubuntu"
  exit 1
fi

echo "Building Docker image (this may take a few minutes)..."
./install.sh

echo
echo   "============================================================"
echo   "| UDP Mass Capture System - Installation Complete           |"
echo   "============================================================"
echo   "| Next steps:                                              |"
echo   "|                                                          |"
echo   "|  1. Test a stream:                                       |"
echo   "|     ./test.sh <your-udp-address>                         |"
echo   "|     (e.g. ./test.sh 239.0.0.1:1234)                      |"
echo   "|     (Use your own UDP address to verify you can receive   |"
echo   "|      data before editing the config)                      |"
echo   "|                                                          |"
echo   "|  2. Edit the configuration file: capture.cfg              |"
echo   "|  3. Start the capture process: ./run.sh                   |"
echo   "|  4. Monitor the session:       ./monitor.sh               |"
echo   "|                                                          |"
echo   "| You are now in the udp-capture-main/src directory.        |"
echo   "============================================================" 