#!/bin/bash
set -e

# Ensure we are in the udp-capture-main directory
if [ "$(basename $(pwd))" != "udp-capture-main" ]; then
  cd udp-capture-main
fi

docker build -t tsduck-capture -f src/Dockerfile src 

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
echo   "| You are now in the udp-capture-main directory.            |"
echo   "============================================================" 
cd udp-capture-main