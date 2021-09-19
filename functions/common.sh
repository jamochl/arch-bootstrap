fn_home_setup() {
    rmdir ~/* &> /dev/null || true
    mkdir ~/{Documents,Pictures,Videos,Downloads}
}

fn_flatpak_setup_n_install() {
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install $(grep '^\w' $PACKAGE_DIR/flatpak_desired.list) --assumeyes --noninteractive
}

fn_pip_setup_n_install() {
    pip3 install --user $(grep '^\w' $PACKAGE_DIR/pip_desired.list)
}

fn_git_setup() {
    git config --global user.name "jamochl"
    git config --global user.email "james.lim@jamochl.com"
    git config --global user.useConfigOnly "true"
    git config --global pull.rebase false # default strategy
}

fn_clone_dotfiles() {
    git clone --bare https://github.com/jamochl/dotfiles ~/.dotfiles
    git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" config status.showUntrackedFiles no
    git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" checkout --force master
}

fn_user_setup() {
    sudo chsh james --shell="/bin/zsh"
}

fn_firewall_setup() {
    sudo systemctl enable --now firewalld
    sudo firewall-cmd --set-default-zone=home
}

fn_vim_setup() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    VIM_PLUG_INSTALL="$(mktemp)"
    cat <<EOF > "$VIM_PLUG_INSTALL"
:PlugInstall!
:qa!
EOF
    vim -s "$VIM_PLUG_INSTALL"
    rm -f "$VIM_PLUG_INSTALL"
}

fn_utility_setup() {
    fn_vim_setup
}

fn_kernel_setup() {
    # Kernel Setup (Metabox Only)
    # Only works for uefi
    if [[ "$(lscpu -J | jq '.lscpu[] | select(.field == "Model name:") | .data')" == '"Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz"' ]]; then
        sudo kernelstub -a "intel_idle.max_cstate=4"
    fi
}
