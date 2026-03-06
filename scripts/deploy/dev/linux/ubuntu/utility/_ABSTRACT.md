# Scripts - Linux

## Environment - Dev

## Platform

* Linux - Ubuntu Desktop

### System

#### Power

* Monitor

```bash
# Display
gsettings set org.gnome.desktop.session idle-delay 0
```

* Disable Suspend

```bash
# AC Power
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Bettery
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
```

* System

```bash
# System
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```
