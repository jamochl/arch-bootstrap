# Core ABI functions, sources distro specific interface as a hook for each

common::home_setup() {
    rmdir ~/* &> /dev/null || true
    mkdir ~/{Documents,Pictures,Videos,Downloads}
    distro::home_setup()
}

common::user_setup() {
    if ! sudo grep --line-regexp "$USER\s*ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers
    then
        echo "$USER   ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    fi
    distro::user_setup
}

common::package_manager_setup() {
    distro::package_manager_setup
}

common::install_pkglists() {
    distro::install_pkglists
    common::flatpak_setup_n_install
    common::pip_setup_n_install
}

common::git_setup() {
    git config --global user.name "jamochl"
    git config --global user.email "james.lim@jamochl.com"
    git config --global user.useConfigOnly "true"
    git config --global pull.rebase false # default strategy
    distro::git_setup
}

common::clone_dotfiles() {
    if git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status; then
        git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" pull
    else
        git clone --bare https://github.com/jamochl/dotfiles ~/.dotfiles
        git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" config status.showUntrackedFiles no
    fi
    git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" checkout --force master
    distro::clone_dotfiles
}

common::service_setup() {
    common::firewall_setup
    distro::service_setup
}

common::utility_setup() {
    common::vim_setup
    common::vscode_setup
    # zsh shell setup
    sudo chsh $USER --shell="/bin/zsh"
    distro::utility_setup
}

common::kernel_setup() {
    distro::kernel_setup
}

# Main function to initiate Bootstrap
common::run_bootstrap() {
    DISTRO_INTERFACE="$1"

    source "$DISTRO_INTERFACE"

    common::home_setup
    common::user_setup
    common::package_manager_setup
    common::install_pkglists
    common::git_setup
    common::clone_dotfiles
    common::service_setup
    common::utility_setup
    common::kernel_setup
    distro::run_bootstrap
}

# Implementation Functions

common::flatpak_setup_n_install() {
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-delete --system flathub 2> /dev/null || true
    flatpak install $(grep '^\w' $PACKAGE_DIR/flatpak_desired.list) --assumeyes --noninteractive
}

common::pip_setup_n_install() {
    pip3 install --user $(grep '^\w' $PACKAGE_DIR/pip_desired.list)
}

common::firewall_setup() {
    sudo systemctl enable --now firewalld
    sudo firewall-cmd --set-default-zone=home
}

common::vim_setup() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    VIM_PLUG_INSTALL="$(mktemp)"
    cat <<EOF > "$VIM_PLUG_INSTALL"
:PlugInstall!
:sleep 35
:qa!
EOF
    vim -s "$VIM_PLUG_INSTALL"
    rm -f "$VIM_PLUG_INSTALL"
}

common::vscode_setup() {
    for EXTENSION in $(grep '^\w' $PACKAGE_DIR/vscode_desired.list); do
        flatpak run com.visualstudio.code --install-extension "$EXTENSION"
    done
}
