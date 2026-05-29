# PhpStorm

## Download

### Install

* Download a file

```text
cd ~/Downloads

wget -O PhpStorm-2026.1.1.tar.gz "https://download.jetbrains.com/webide/PhpStorm-2026.1.1.tar.gz"
```

* Unzip a file

```text
sudo tar -xzf ~/Downloads/PhpStorm-2026.1.1.tar.gz -C /opt

ls /opt | grep -i phpstorm
```

* Rename a folder

```text
sudo mv /opt/PhpStorm{version} /opt/phpstorm
```

* Run Phpstorm

```text
/opt/phpstorm/bin/phpstorm
```

* Edit a link file

```text
sudo vi /usr/share/applications/phpstorm.desktop
~

[Desktop Entry]
Version=1.0
Type=Application
Name=PhpStorm
Icon=/opt/phpstorm/bin/phpstorm.png
Exec="/opt/phpstorm/bin/phpstorm" %f
Comment=PhpStorm - PHP IDE by JetBrains
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-phpstorm
StartupNotify=true
```

* Add a configration related keyboard

```text
sudo vi /opt/phpstorm/bin/phpstorm.sh
~

export XMODIFIERS=@im=ibus
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
```

* Add a PATH

```text
echo 'export PATH="/opt/phpstorm/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc


phpstorm
```

### Remove application

* Remove a directory

```text
sudo rm -rf /opt/PhpStorm*
```

```text
sudo rm -rf /opt/phpstorm*
```

* Remove a file

```text
rm -f ~/.local/share/applications/jetbrains-phpstorm.desktop
```

```text
sudo rm -f /usr/share/applications/phpstorm.desktop
```

```text
sudo rm -f /opt/phpstorm/bin/phpstorm.sh
```

* Remove cache files

```text
rm -rf ~/.config/JetBrains/PhpStorm*
```

```text
rm -rf ~/.cache/JetBrains/PhpStorm*
```

```text
rm -rf ~/.local/share/JetBrains/PhpStorm*
```

## Reference

* IDE
  * [PhpStorm](https://www.jetbrains.com/phpstorm)
    * Settings
      * PHP
        * Xdebug - [Configuration](https://www.jetbrains.com/help/phpstorm/debugging-with-phpstorm-ultimate-guide.html)
      * Deployment - [Deploying application](https://www.jetbrains.com/help/phpstorm/deploying-applications.html)
      * [Symfony Framework](https://www.jetbrains.com/help/phpstorm/symfony-support.html#use_symfony_cli)
    * Plugin
      * draw.io - [Integration](https://plugins.jetbrains.com/plugin/15635-diagrams-net-integration)
