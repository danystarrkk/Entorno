#!/usr/bin/bash

set -Eeuo pipefail

############# Colores ##############

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

###################################

########## Salir ########

function ctrl_c() {
  echo -e ""
  exit 130
}

function errReport() {
  echo -e "\n${redColour}[!] Error en la línea ${1} al ejecutar: ${2}${endColour}"
}

trap ctrl_c SIGINT
trap 'errReport "${LINENO}" "${BASH_COMMAND}"' ERR

#########################

####### Varibles Globales ######

rutaP="$HOME"
rutaE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
rutaT="$rutaE/configs"

################################

############## Funciones Globales #############

function installDependencias() {

  clear

  echo -e "\n\t ${blueColour} Instalación del Entorno \n\n${endColour}"

  echo -en "${turquoiseColour}[1] Instalar dependencias [y/n]: ${endColour}" && read opt1
  opt1="${opt1:-n}"

  if [[ "$opt1" == "y" ]]; then
    echo -e "\n${purpleColour}    [+] Instalando Dependencias......${endColour}"

    sudo pacman -Syu

    sudo pacman -S --needed --noconfirm base-devel git

    echo -e "${blueColour}[+] Instalando repositorio BlackArch...${endColour}"

    strapDir="$(mktemp -d)"

    if curl -fsSL -o "${strapDir}/strap.sh" https://blackarch.org/strap.sh &&
      curl -fsSL -o "${strapDir}/strap.sh.sha1" https://blackarch.org/strap.sh.sha1 &&
      (cd "${strapDir}" && sha1sum -c strap.sh.sha1); then
      chmod +x "${strapDir}/strap.sh"
      sudo "${strapDir}/strap.sh" || echo -e "${yellowColour}[!] Falló la ejecución de strap.sh, se continúa sin el repositorio BlackArch....${endColour}"
    else
      echo -e "${yellowColour}[!] Falló la descarga o la verificación SHA1 de strap.sh, se continúa sin el repositorio BlackArch....${endColour}"
    fi

    rm -rf "${strapDir}"

    sudo pacman -Syu

    sudo pacman -S --noconfirm --needed nautilus nmap arp-scan gobuster openbsd-netcat openssh python wget ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-ubuntu-font-family ttf-opensans ttf-roboto adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts xdg-user-dirs

    if grep -qE '^[[:space:]]*\[blackarch\]' /etc/pacman.conf; then
      echo -e "${blueColour}[+] Instalando herramientas de BlackArch...${endColour}"

      sudo pacman -S --noconfirm --needed whatweb ffuf wfuzz burpsuite seclists || echo -e "${yellowColour}[!] Error instalando herramientas de BlackArch, se continúa....${endColour}"

      echo -e "${greenColour}[+] Repositorio BlackArch instalado correctamente${endColour}"
    else
      echo -e "${yellowColour}[!] El repositorio BlackArch no está habilitado en /etc/pacman.conf, se omiten sus herramientas....${endColour}"
    fi

    echo -e "${blueColour}[+] Instalando yay ${endColour}\n"

    if [ ! -d "${rutaT}/yay" ]; then
      git clone https://aur.archlinux.org/yay.git "${rutaT}/yay"
    else
      echo -e "${yellowColour}    [!] Ya existe ${rutaT}/yay, se omite la clonación....${endColour}"
    fi

    cd "${rutaT}/yay"
    makepkg -si
    cd "${rutaE}"

    if yay -S --noconfirm dconf glib2 arc-gtk-theme papirus-icon-theme jdk22-graalvm-bin net-tools flameshot pocl xclip xsel neovim xorg-xsetroot vim zsh bspwm sxhkd picom polybar rofi feh kitty zsh-syntax-highlighting bat lsd npm open-vm-tools wmname dash glib2-devel gtkmm3 firefox docker docker-compose unzip sddm arandr nitrogen less tree ripgrep maim dunst libnotify xdotool alsa-utils viewnior i3lock-fancy mpc xorg-xrandr xorg-setxkbmap; then
      echo -e "${greenColour}    [+] Instalación de dependecias correctamente.....${endColour}"
    else
      echo -e "${redColour}    [!] Error en la Instalación de Dependencias....${endColour}"
    fi

  else
    echo -e "\n\t${redColour}[!] No se instalaran las dependecias, no se recomienda omitir este paso...  ${endColour}"
  fi

}

function configuracionEntorno() {

  echo -en "\n${blueColour}[2] Desea configurar el Entorno [y/n]:${endColour}" && read opt1
  opt1="${opt1:-n}"

  if [[ "$opt1" == "y" ]]; then

    echo -e "\n${turquoiseColour}[+] Configuración del Entorno: ${endColour}"

    xdg-user-dirs-update --force
    wget -P $rutaT https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    mkdir -p $rutaT/fonts/HackNerdFonts
    unzip -o $rutaT/Hack.zip -d $rutaT/fonts/HackNerdFonts
    rm -rf $rutaT/Hack.zip

    wget -P $rutaT https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    mkdir -p $rutaT/fonts/JetBrainsMono
    unzip -o $rutaT/JetBrainsMono.zip -d $rutaT/fonts/JetBrainsMono
    rm -rf $rutaT/JetBrainsMono.zip

    mkdir -p $rutaP/.config/bin
    touch $rutaP/.config/bin/target

    cp -r $rutaT/bspwm $rutaP/.config
    cp -r $rutaT/sxhkd $rutaP/.config

    chsh -s /bin/zsh
    sudo chsh -s /bin/zsh

    chmod +x $HOME/.config/bspwm/scripts/*

    cp -r $rutaT/wallpapers $rutaP/Pictures

    if [ ! -d "$rutaP/.config/nvim" ]; then
      git clone --depth=1 https://github.com/danystarrkk/nvim "$rutaP/.config/nvim"
    else
      echo -e "${yellowColour}    [!] Ya existe $rutaP/.config/nvim, se omite la clonación....${endColour}"
    fi

    cp -r $rutaT/kitty $rutaP/.config
    sudo cp -r $rutaT/kitty /root/.config

    sudo cp -r $rutaT/fonts/* /usr/share/fonts
    sudo fc-cache -fv

    cp -r $rutaT/picom $rutaP/.config

    sudo mkdir -p /usr/share/zsh-sudo/

    sudo wget -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh &>/dev/null
    sudo systemctl enable vmtoolsd.service || echo -e "${yellowColour}[!] No se pudo habilitar vmtoolsd.service, se continúa....${endColour}"
    sudo systemctl enable vmware-vmblock-fuse.service || echo -e "${yellowColour}[!] No se pudo habilitar vmware-vmblock-fuse.service, se continúa....${endColour}"
    sudo systemctl enable docker.service || echo -e "${yellowColour}[!] No se pudo habilitar docker.service, se continúa....${endColour}"

    cd

    if [ ! -d "$HOME/powerlevel10k" ]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe ~/powerlevel10k, se omite la clonación....${endColour}"
    fi

    rm -rf $rutaP/.p10k.zsh
    rm -rf $rutaP/.zshrc

    cp $rutaT/files/.zshrc $HOME
    cp $rutaT/files/.p10k.zsh $HOME

    sudo touch /root/.zshrc

    if ! sudo test -d /root/powerlevel10k; then
      sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe /root/powerlevel10k, se omite la clonación....${endColour}"
    fi

    sudo rm -rf /root/.p10k.zsh
    sudo rm -rf /root/.zshrc

    sudo cp $rutaT/files_root/.zshrc /root
    sudo cp $rutaT/files_root/.p10k.zsh /root

    sudo cp -r $rutaT/kitty /root/.config/

    rm -rf ~/.config/polybar/
    cp -r $rutaT/polybar $HOME/.config
    cp -r $rutaT/rofi $rutaP/.config
    chmod +x $rutaP/.config/rofi/bin/*

    echo -e "${blueColour}[+] Instalando SDDM mínimo...${endColour}"

    # Habilitar el servicio de SDDM
    sudo systemctl enable sddm.service || echo -e "${yellowColour}[!] No se pudo habilitar sddm.service, se continúa....${endColour}"

    # Crear archivo de sesión para bspwm
    sudo tee /usr/share/xsessions/bspwm.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary space partitioning window manager
Exec=bspwm
Type=Application
EOF

    # Dark theme and icons
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || echo -e "${yellowColour}[!] No se pudo aplicar 'prefer-dark' con gsettings, se continúa....${endColour}"
    gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark' 2>/dev/null || echo -e "${yellowColour}[!] No se pudo aplicar 'Arc-Dark' con gsettings, se continúa....${endColour}"
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || echo -e "${yellowColour}[!] No se pudo aplicar 'Papirus-Dark' con gsettings, se continúa....${endColour}"

    mkdir -p ~/.config/gtk-3.0

    tee ~/.config/gtk-3.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
EOF

    cd
    if [ ! -d "$HOME/.fzf" ]; then
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
      echo -e "${yellowColour}    [!] Ya existe ~/.fzf, se omite la clonación....${endColour}"
    fi
    ~/.fzf/install --all

    if ! sudo test -d /root/.fzf; then
      sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
    else
      echo -e "${yellowColour}    [!] Ya existe /root/.fzf, se omite la clonación....${endColour}"
    fi
    sudo /root/.fzf/install --all

    echo -e "${blueColour}[+] Aplicando variables globales para Tema Oscuro...${endColour}"

    # 1. Forzar a las aplicaciones Qt a usar el motor de GTK3 y tu tema
    for lineaEnv in "QT_QPA_PLATFORMTHEME=gtk3" "QT_STYLE_OVERRIDE=kvantum" "GTK_THEME=Arc-Dark"; do
      if ! sudo grep -qxF "${lineaEnv}" /etc/environment; then
        echo "${lineaEnv}" | sudo tee -a /etc/environment >/dev/null
      fi
    done

    # 2. Asegurar que las aplicaciones GTK4 (si instalas alguna) también sean oscuras
    mkdir -p ~/.config/gtk-4.0
    tee ~/.config/gtk-4.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
EOF

    # 3. Configurar el tema oscuro para el usuario root (vital cuando abres herramientas con sudo)
    sudo mkdir -p /root/.config/gtk-3.0
    sudo tee /root/.config/gtk-3.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
EOF

    # Con set -e, llegar hasta aquí significa que no hubo errores fatales
    echo -e "\n${greenColour}[+] Se completo la configuración del Entorno.... ${endColour}"
  else
    echo -e "${redColour}\n\t[!] Configuración del Entorno Cancelado...\n\n${endColour}"
  fi

}

##### Orden de Ejecución #########

echo -e "${blueColour}[*] Introduce tu contraseña de sudo (solo te la pediremos esta vez):${endColour}"
sudo -v

# Bucle en segundo plano que mantiene sudo activo mientras el script esté corriendo
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

installDependencias
configuracionEntorno
