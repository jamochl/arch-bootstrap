fn_apt_setup() {
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

fn_install_dependencies() {
    sudo apt update && sudo apt upgrade -y --allow-downgrades
    sudo apt install -y $(cat $PACKAGE_DIR/{common_desired,ubuntu_desired}.list | grep '^\w')
}

fn_virtualisation_setup() {
    sudo usermod $USER -aG kvm,libvirt
    sudo chsh james --shell="/bin/zsh"

    # libvirt Firewalld
    sudo firewall-cmd --new-zone=libvirt --permanent
    sudo firewall-cmd --zone=libvirt --add-service={ssh,dhcpv6,dhcp,http,https,dns,tftp} --permanent
    sudo firewall-cmd --zone=libvirt --add-protocol={icmp,ipv6-icmp} --permanent
    sudo firewall-cmd --zone=libvirt --set-target=ACCEPT --permanent
    sudo firewall-cmd --zone=libvirt --add-rich-rule='rule priority="32767" reject' --permanent
    sudo firewall-cmd --reload

    sudo systemctl enable libvirtd
    sudo systemctl restart libvirtd
}

