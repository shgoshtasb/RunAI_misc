#!/bin/bash

# Exit immediatly if a command has non-zero status
set -e

# Treat unset variables as an error when substituting
#set -u

# Setup ssh server
#source ./runai/scripts/helperfunctions.sh
apt update 2>/dev/null >/dev/null;
echo "America/New_York" > /etc/timezone
apt install -y tzdata 2>/dev/null >/dev/null
#apt install -y tmux 2>/dev/null >/dev/null
#apt install -y vim 2>/dev/null >/dev/null
#apt install -y git 2>/dev/null >/dev/null

# Source the workspace setup
source ./runai/scripts/workspace_setup.sh

# Check if GPU available
#nvidia-smi

mkdir -p logs
mkdir -p jobs

echo "$cmdline >> logs/${job_id}"
echo "$cmdline" >> jobs/${job_id}
chmod +x jobs/${job_id}
jobs/${job_id} >> logs/${job_id} 2>&1

