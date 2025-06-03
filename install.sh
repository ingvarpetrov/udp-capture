#!/bin/bash
set -e

docker build -t tsduck-capture -f src/Dockerfile src 