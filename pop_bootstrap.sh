#!/bin/bash -ex

# Bootstrap Pop!_OS Linux

# File setup
rmdir ~/*
mkdir ~/{Documents,Pictures,Videos,Downloads}

# Environment setup
PACKAGE_DIR="$HOME/.config/packagelists"

# Initial System Setup
## Setup APT
cat <<EOF | sudo tee /etc/apt/apt.conf
APT::Install-Recommends "False";
APT::Cache::ShowRecommends "True";
EOF

sudo cp /etc/apt/sources.list{,~}
sudo sed -i 's/us\.archive/au.archive/g' /etc/apt/sources.list
if [[ -f '/etc/apt/sources.d/system.sources' ]]; then
    sudo sed -i 's/us\.archive/au.archive/g' '/etc/apt/sources.list.d/system.sources'
fi

sudo systemctl disable apt-daily-upgrade.timer apt-daily.timer
sudo systemctl mask apt-daily-upgrade apt-daily

sudo apt update && sudo apt upgrade -y

# Setup GIT
sudo apt install -y git

git config --global user.name "jamochl"
git config --global user.email "james.lim@jamochl.com"
git config --global user.useConfigOnly "true"
git config --global pull.rebase false # default strategy

# Setup dotfiles
git clone --bare https://github.com/jamochl/dotfiles ~/.dotfiles
git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" config status.showUntrackedFiles no
git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" checkout --force master

# Install dependencies
sudo apt install -y $(cat $PACKAGE_DIR/{common_desired,ubuntu_desired}.list | grep '^\w')

## Setup Flatpak
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install $(grep '^\w' $PACKAGE_DIR/flatpak_desired.list) --assumeyes --noninteractive

## Setup aws-cli
pip3 install --user awscli

# Setup Firewalld
sudo firewall-cmd --set-default-zone=home

# Setup Virtualisation

## User setup
sudo usermod $USER -aG kvm,libvirt

## libvirt Firewalld
sudo firewall-cmd --new-zone=libvirt --permanent
sudo firewall-cmd --zone=libvirt --add-service={ssh,dhcpv6,dhcp,http,https,dns,tftp} --permanent
sudo firewall-cmd --zone=libvirt --add-protocol={icmp,ipv6-icmp} --permanent
sudo firewall-cmd --zone=libvirt --set-target=ACCEPT --permanent
sudo firewall-cmd --zone=libvirt --add-rich-rule='rule priority="32767" reject' --permanent
sudo firewall-cmd --reload

sudo systemctl enable libvirtd
sudo systemctl restart libvirtd

# Service setup
sudo systemctl disable NetworkManager-wait-online.service

# Kernel Setup (Metabox Only)
# Only works for uefi
if [[ "$(lscpu -J | jq '.lscpu[] | select(.field == "Model name:") | .data')" == '"Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz"' ]]; then
    sudo kernelstub -a "intel_idle.max_cstate=4"
fi
