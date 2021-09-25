# System Bootstrap

Bootstrapping Pop OS or Arch Linux with my Dotfiles and preferred system
setup (Applications, Configuration, firewall, etc).

* POP Bootstrap (Working)
* Arch Bootstrap (Working)

# Instructions

## Pop!\_OS Bootstrap

```bash
git clone https://github.com/jamochl/system-bootstrap
cd system-bootstrap
./pop_bootstrap.sh
```

## Arch Bootstrap

```bash
git clone https://github.com/jamochl/system-bootstrap
cd system-bootstrap
./arch_bootstrap.sh
```

# How it works

## Bash

The common.sh library in the libraries folder holds the core ABI interface of
what I want to achieve with the bootstrap.

```bash
common::home_setup
common::user_setup
common::package_manager_setup
common::install_pkglists
common::git_setup
common::clone_dotfiles
common::service_setup
common::utility_setup
common::kernel_setup
```

These are all functions which perform system agnostic setup. Each function
has a post hook that allows for distribution specific setup in each stage.
Functions are implemented via distro::{{ function\_name }} variant, in a
bash library such as ubuntu.sh or arch.sh

The bootstrap is kicked off by passing a distribution specific bash
library, (eg. library/ubuntu.sh) to the common::run\_bootstrap function.

The library ubuntu.sh would implement the following.

```bash
distro::home_setup
distro::user_setup
distro::package_manager_setup
distro::install_pkglists
distro::git_setup
distro::clone_dotfiles
distro::service_setup
distro::utility_setup
distro::kernel_setup
```

This acts similar to OOP interface composition. If a new distro is created,
such as fedora, I can make a fedora.sh library to implement distro specific
functions to perform distro specific actions (eg. dnf update -y), while
common logic is handled by common.sh library

## Packages

As well, packages are defined in the pkglists/ folder in a shell format
(empty lines and comments will be ignored). This is to get declarative
behaviour, and there is a list for package managers, vscode extensions,
pip, and flatpak applications.
