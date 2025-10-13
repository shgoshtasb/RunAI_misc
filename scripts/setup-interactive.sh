#!/bin/bash

# Setup ssh server
apt update
echo "America/New_York" > /etc/timezone
apt install -y tzdata

apt install -y tmux
apt install -y vim
apt install -y git
apt install -y font-manager

git config --global user.email "$git_email"

source ./runai/scripts/helperfunctions.sh
check_if_interactive_and_login_shell
checkifroot
ssh_enable_ubuntu

source /myhome/.bashrc

sleep 24h
