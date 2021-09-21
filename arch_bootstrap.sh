#!/bin/bash -ex

# Bootstrap Pop!_OS Linux
source functions/common.sh
source functions/arch.sh

# Environment setup
PACKAGE_DIR="$PWD/pkglists"

fn_home_setup
fn_user_setup
fn_package_manager_setup
fn_install_pkglists
fn_git_setup
fn_clone_dotfiles
fn_service_setup
fn_utility_setup
fn_kernel_setup
