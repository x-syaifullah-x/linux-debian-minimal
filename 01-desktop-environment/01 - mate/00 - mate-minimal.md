# DESKTOP ENVIRONMENT MATE MINIMAL
#
#
#### MATE MINIMAL
```bash
PACKAGES=(
    marco
    mate-session-manager
    mate-panel
    mate-settings-daemon-common
    xserver-xorg-input-libinput
)
apt install --no-install-recommends --no-install-suggests "${PACKAGES[@]}"
```

#### XINIT
```bash
apt install --no-install-recommends --no-install-suggests xinit
```