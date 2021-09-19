fn_package_manager_setup() {
    sudo sed -i 's/#Color/Color/;s/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
}

fn_install_dependencies() {
    sudo pacman -Syu
    sudo pacman -S $(cat $PACKAGE_DIR/{common_desired,arch_desired}.list | grep '^\w')
    fn_flatpak_setup_n_install
    fn_pip_setup_n_install
}

fn_virtualisation_setup() {
    sudo usermod $USER -aG kvm,libvirt
    sudo systemctl enable --now libvirtd
}

fn_service_setup() {
    sudo systemctl enable gdm
    sudo systemctl enable man-db.timer
    fn_network_setup
    fn_print_setup
    fn_sound_setup
    fn_firewall_setup
    fn_virtualisation_setup
}

fn_network_setup() {
    sudo systemctl enable --now NetworkManager
    sudo systemctl disable NetworkManager-wait-online.service
}

fn_print_setup() {
    sudo systemctl enable cups.socket
    sudo systemctl enable avahi-daemon
    sudo systemctl disable systemd-resolved
    echo 'a4' | sudo tee /etc/papersize > /dev/null
    sudo sed -i 's/hosts: .*/hosts: files mymachines myhostname mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns' /etc/nsswitch.conf
    sudo systemctl enable cups-browsed.service
}

fn_sound_setup() {
    sudo tee -a /etc/environment <<EOF
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
MOZ_ENABLE_WAYLAND=1
EOF
}
