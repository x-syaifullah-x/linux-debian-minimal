# SETUP BOOTLOADER
#
#
### MOUNT EFI PARTIION
```sh
 sudo mount -v--label EFI /boot/efi --mkdir
```

### INSTALL PACKAGE
```sh
sudo apt install --no-install-recommends --no-install-suggests efibootmgr grub-efi-amd64 grub-efi-amd64-signed shim-signed
```

### CREATE BOOTLOADER
- **ENV**
    ```sh
    BOOTLOADER_ID=Debian
    ```

- **INSTALL GRUB**
    ```sh
    sudo grub-install --verbose --no-nvram --recheck --compress=no --bootloader-id=$BOOTLOADER_ID --boot-directory=/boot
    ```

- **BOOT WITH NVRAM**
    ```sh
    modprobe --verbose efivarfs
    mount --verbose -t efivarfs efivarfs /sys/firmware/efi/efivars
    efibootmgr --verbose --create --disk /dev/sda --part 4 --label "Debian Boot Manager" --loader "/EFI/$BOOTLOADER_ID/shimx64.efi"
    ```

- **BOOT WITHOUT NVRAM**
    ```sh
    sudo mkdir -pv /boot/efi/EFI/Boot
    sudo mkdir cp -rfvp /boot/efi/EFI/$BOOTLOADER_ID/{shimx64.efi,grubx64.efi} /boot/efi/EFI/Boot
    sudo mv /boot/efi/EFI/Boot/shimx64.efi /boot/efi/EFI/Boot/bootx64.efi
    ```

### SETUP GRUB
- **Setup File /etc/default/grub**
    ```bash
    cat << EOF > /etc/default/grub
    GRUB_DEFAULT=0
    GRUB_TIMEOUT=5
    GRUB_DISTRIBUTOR="Debian Boot Manager"
    GRUB_CMDLINE_LINUX_DEFAULT="quiet modprobe.blacklist=dm_mod,uas,usb_storage,at24,b43,bcma,brcmsmac,efi_pstore,iTCO_wdt,r8169,uvcvideo mitigations=off acpi_enforce_resources=no reboot=pci acpi_osi=Linux nmi_watchdog=0 systemd.gpt_auto=0 lsm= fsck.mode=skip"
    GRUB_CMDLINE_LINUX=""
    GRUB_DISABLE_OS_PROBER=false
    GRUB_GFXMODE=$(cat /sys/class/drm/*/modes | head -1)
    GRUB_DISABLE_LINUX_UUID=true
    GRUB_DISABLE_RECOVERY="true"
    GRUB_DISABLE_SUBMENU=y
    GRUB_BACKGROUND=/boot/theme/background.png
    GRUB_THEME=/boot/theme/theme.txt
    EOF
    ```

    - **Setup Grub Theme**

        - **[Download Theme](https://github.com/x-syaifullah-x/install-linux/blob/master/Others/z-Files/boot/theme.tar.gz)**

        - **COPY DIRECTORY THEME TO BOOT**
            ```bash
            cp -rfv theme /boot
            ```

        - **Config Theme**
            ```bash
            cat << EOF >> /etc/default/grub
            GRUB_BACKGROUND=/boot/theme/background.png
            GRUB_THEME=/boot/theme/theme.txt
            EOF
            ```

- **Update grub.cfg**
    ```bash
    update-grub
    ```
    - **Without Grub Menu**
        ```bash
        cat << EOF > /boot/grub/grub.cfg
        terminal_output gfxterm
        background_image -m normal $prefix/bg.png
        set default=0
        set gfxpayload=keep
        set pager=1
        set timeout=0
        menuentry '' {
            linux /boot/vmlinuz-6.13-amd64 quiet modprobe.blacklist=dm_mod,uas,usb_storage,at24,b43,bcma,brcmsmac,efi_pstore,iTCO_wdt,r8169,uvcvideo mitigations=off acpi_enforce_resources=no reboot=pci acpi_osi=Linux nmi_watchdog=0 systemd.gpt_auto=0 lsm= fsck.mode=skip
            initrd /boot/initrd.img-6.13-amd64
        }
        EOF
        ```