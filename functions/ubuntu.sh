fn_package_manager_setup() {
    cat <<EOF | sudo tee /etc/apt/apt.conf
APT::Install-Recommends "False";
APT::Cache::ShowRecommends "True";
EOF

    sudo cp /etc/apt/sources.list{,~}
    sudo sed -i 's/us\.archive/au.archive/g' /etc/apt/sources.list
    if [[ -f '/etc/apt/sources.list.d/system.sources' ]]; then
        sudo sed -i '/URIs:/s/us\.archive/au.archive/' /etc/apt/sources.list.d/system.sources
    fi

    sudo systemctl disable apt-daily-upgrade.timer apt-daily.timer
    sudo systemctl mask apt-daily-upgrade apt-daily
}

fn_install_pkglists() {
    sudo apt update && sudo apt upgrade -y --allow-downgrades
    sudo apt install -y $(cat $PACKAGE_DIR/{common_desired,ubuntu_desired}.list | grep '^\w')
    fn_flatpak_setup_n_install
    fn_pip_setup_n_install
}

fn_virtualisation_setup() {
    sudo usermod $USER -aG kvm,libvirt

    # libvirt Firewalld
    if ! sudo firewall-cmd --info-zone=libvirt; then
        sudo firewall-cmd --new-zone=libvirt --permanent
    fi
    sudo firewall-cmd --zone=libvirt --add-service={ssh,dhcpv6,dhcp,http,https,dns,tftp} --permanent
    sudo firewall-cmd --zone=libvirt --add-protocol={icmp,ipv6-icmp} --permanent
    sudo firewall-cmd --zone=libvirt --set-target=ACCEPT --permanent
    sudo firewall-cmd --zone=libvirt --add-rich-rule='rule priority="32767" reject' --permanent
    sudo firewall-cmd --reload

    sudo systemctl enable libvirtd
    sudo systemctl restart libvirtd
}

fn_service_setup() {
    fn_firewall_setup
    fn_virtualisation_setup
    fn_podman_setup
    sudo systemctl disable NetworkManager-wait-online.service
}

fn_podman_setup() {
    echo 'L+ /run/docker.sock - - - - /run/podman/podman.sock' | sudo tee /etc/tmpfiles.d/podman-to-docker.conf
    sudo systemd-tmpfiles --create
}
