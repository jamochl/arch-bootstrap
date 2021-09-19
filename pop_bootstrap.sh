#!/bin/bash -ex

# Bootstrap Pop!_OS Linux
source functions/common.sh
source functions/ubuntu.sh

# Environment setup
PACKAGE_DIR="$PWD/pkglists"

fn_home_setup
fn_apt_setup
fn_install_dependencies
fn_git_setup
fn_clone_dotfiles
fn_flatpak_setup
fn_pip_setup
fn_firewalld_setup
fn_virtualisation_setup
fn_network_manager_setup
fn_vim_setup
fn_kernel_setup
