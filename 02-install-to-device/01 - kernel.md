# SETUP KERNEL
#
#
#### Install Kernel
```sh
apt install --no-install-recommends --no-install-suggests linux-image-6.12.12+bpo-amd64
```

#### Remove OLD Kernel
```sh 
rm -rfv /initrd.img.old /vmlinuz.old
```

#### Update Initramfs Config
```sh 
sed -i 's/update_initramfs=yes/update_initramfs=no/' /etc/initramfs-tools/update-initramfs.conf
```

#### Update Initramfs Config
```sh
sed -i 's/^#\?BUSYBOX=.*/BUSYBOX=n/' /etc/initramfs-tools/initramfs.conf
sed -i 's/^#\?COMPRESS=.*/COMPRESS=gzip/' /etc/initramfs-tools/initramfs.conf
sed -i 's/^#\?COMPRESSLEVEL=.*/COMPRESSLEVEL=1/' /etc/initramfs-tools/initramfs.conf
```

#### Update Initramfs
```sh
update-initramfs -v -d -c -k all
```