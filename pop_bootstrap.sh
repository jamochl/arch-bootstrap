#!/bin/bash -ex

# Bootstrap Pop!_OS Linux

# Environment setup
local PACKAGE_DIR="$HOME/.config/packagelists"

# Initial System Setup
sudo apt update && sudo apt upgrade -y

# Setup GIT
sudo apt install -y git

git config --global user.name "jamochl"
git config --global user.email "james.lim@jamochl.com"
git config --global user.useConfigOnly "true"

# Setup dotfiles
git clone --bare https://github.com/jamochl/dotfiles ~/.dotfiles
git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" config status.showUntrackedFiles no
git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" checkout --force master

# Setup APT
cat <<EOF | sudo tee /etc/apt/apt.conf
APT::Install-Recommends "False";
APT::Cache::ShowRecommends "True";
EOF

# Install dependencies
sudo apt install -y $(cat $PACKAGE_DIR/{common_desired,ubuntu_desired}.list | grep '^\w')

## Setup Flatpak


# Service setup
sudo systemctl disable NetworkManager-wait-online.service

# Kernel Setup (Metabox Only)
if [[ "$(lscpu -J | jq '.lscpu[] | select(.field == "Model name:") | .data')" == '"Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz"' ]]; then
    sudo kernelstub -a "intel_idle.max_cstate=4"
fi
