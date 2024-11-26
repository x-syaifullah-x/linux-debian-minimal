### ROOTFS DEBIAN ARM64
#
#
[Download Base System](https://github.com/x-syaifullah-x/install-debian/releases/download/bookworm-arm64/rootfs_arm64.tar.xz)

[See Setup Rootfs](https://github.com/x-syaifullah-x/install-debian/blob/master/README.md)

### SYSCTL CONFIG
```sh
cat << EOF | tee /etc/sysctl.d/proc.sys.conf
kernel.printk = 0 4 1 7
EOF
```

### SETUP HOTSPOT
- **WITH HOSTAPD**
    - **Install Packages**
        ```sh
        apt install --no-install-recommends --no-install-suggests hostapd
        ```

    - **Setup ENV**
        ```sh
        _interface=wlan0
        ```

    - **Config hostapd**
        ```sh
        sed -i 's/^#\?DAEMON_CONF=.*/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/' /etc/default/hostapd
        
        cat << EOF | tee /etc/hostapd/hostapd.conf
        interface=$_interface
        driver=nl80211
        ieee80211n=1
        ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40]
        ssid=$(cat /etc/hostname)
        # HW MODE
        #   a : 5GHz
        #   b : 2.4GHz
        hw_mode=g
        channel=6
        wmm_enabled=0
        macaddr_acl=0
        auth_algs=1
        # IGNORE BROADCASE SSID
        #   0: visible
        #   1: hidden
        ignore_broadcast_ssid=0
        wpa=2
        wpa_passphrase=3172041902920013
        wpa_key_mgmt=WPA-PSK
        rsn_pairwise=TKIP CCMP
        ctrl_interface=/var/run/hostapd
        ctrl_interface_group=0
        ap_isolate=0
        EOF
        ```

- **WITH WPA_SUPPLICANT**
    - **Install Packages**
        ```sh
        apt install --no-install-recommends --no-install-suggests wpasupplicant
        ```
    
    - **Create Config WPA_SUPPLICANT**
        ```sh
        cat << EOF | tee /etc/wpa_supplicant/wlan0-ap.conf
        ctrl_interface=/run/wpa_supplicant
        ap_scan=2
        network={
            ssid="s905x"
            mode=2
            frequency=2412
            key_mgmt=WPA-PSK
            proto=RSN
            pairwise=CCMP
            group=CCMP
            psk="3172041902920013"
        }
        EOF
        ```

    - **Create Service**
        ```sh
        cat << EOF | tee /etc/systemd/system/wpa-ap@.service
        [Unit]
        Description=WPA Supplicant AP (%i)
        After=network-pre.target
        Wants=network-pre.target

        [Service]
        ExecStart=/sbin/wpa_supplicant -i %i -c /etc/wpa_supplicant/%i-ap.conf
        Restart=always

        [Install]
        WantedBy=multi-user.target
        EOF
        ```

### SETUP NETWORKD
- **Config ETH_0 || LAN**
    ```sh
    cat << EOF | tee /etc/systemd/network/20-eth0.network
    [Match]
    Name=eth0

    [Network]
    Address=192.168.0.1/24
    DHCPServer=yes
    IPMasquerade=yes
    
    [DHCPServer]
    PoolOffset=2
    PoolSize=9
    DNS=192.168.0.1
    DNS=8.8.8.8
    EOF
    ```

- **Config WLAN_0 | HOTSPOT**
    ```sh
    cat << EOF | tee /etc/systemd/network/20-wlan0.network
    [Match]
    Name=wlan0
    
    [Network]
    Address=192.168.1.1/24
    DHCPServer=yes
    IPMasquerade=yes
    
    [DHCPServer]
    PoolOffset=2
    PoolSize=9
    DNS=192.168.1.1
    DNS=8.8.8.8
    EOF
    ```

- **Config WLAN_1 | INTERNET**
    ```sh
    cat << EOF | tee /etc/systemd/network/20-wlan1.network
    [Match]
    Name=wlan1
    
    [Network]
    DHCP=yes
    EOF
    ```

- **Systemd NETWORKD_ Service**
    ```sh
    _service_name=systemd-networkd_.service
    cat << EOF | tee /etc/systemd/system/$_service_name
    [Unit]
    Description=Restart Systemd Networkd
    After=network.target

    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c "systemctl restart systemd-networkd --now"

    [Install]
    WantedBy=multi-user.target
    EOF
    systemctl enable $_service_name
    ```

### SETUP SSH SERVER
```sh
apt install --no-install-recommends --no-install-suggests openssh-server
mkdir --mode=0700 --parents ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
```