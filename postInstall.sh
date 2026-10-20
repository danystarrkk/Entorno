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

    sudo apt update -y && sudo apt upgrade -y

    sudo apt install -y fonts-dejavu fonts-liberation fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-noto-extra fonts-ubuntu fonts-roboto fonts-open-sans

    # Transacción apt única con paquetes de kali-rolling (todos verificados en pkg.kali.org).
    # Kali ya trae las herramientas pentest: no hay AUR/yay ni BlackArch que gestionar.
    sudo apt install -y dconf-cli libglib2.0-bin arc-theme papirus-icon-theme flameshot pocl-opencl-icd xclip xsel neovim x11-xserver-utils bspwm sxhkd picom polybar rofi feh kitty zsh-syntax-highlighting bat lsd npm wmname libglib2.0-dev docker.io docker-compose arandr ripgrep open-vm-tools open-vm-tools-desktop mesa-utils xdg-user-dirs maim dunst libnotify-bin xdotool alsa-utils viewnior i3lock-fancy mpc mpd x11-xkb-utils

    echo -e "${greenColour}    [+] Instalación de dependecias correctamente.....${endColour}"

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
    wget -P "$rutaT" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    mkdir -p "$rutaT/fonts/HackNerdFonts"
    unzip -o "$rutaT/Hack.zip" -d "$rutaT/fonts/HackNerdFonts"
    rm -rf "$rutaT/Hack.zip"

    wget -P "$rutaT" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    mkdir -p "$rutaT/fonts/JetBrainsMono"
    unzip -o "$rutaT/JetBrainsMono.zip" -d "$rutaT/fonts/JetBrainsMono"
    rm -rf "$rutaT/JetBrainsMono.zip"

    mkdir -p "$rutaP/.config/bin"
    touch "$rutaP/.config/bin/target"

    cp -r "$rutaT/bspwm" "$rutaP/.config"
    cp -r "$rutaT/sxhkd" "$rutaP/.config"

    chsh -s /bin/zsh
    sudo chsh -s /bin/zsh

    chmod +x "$HOME/.config/bspwm/scripts/"*

    mkdir -p "$rutaP/Imágenes"
    cp -r "$rutaT/wallpapers" "$rutaP/Imágenes"

    # Neovim externo: solo usuario, sin nvim para root
    if [ ! -d "$rutaP/.config/nvim" ]; then
      git clone --depth=1 https://github.com/danystarrkk/nvim "$rutaP/.config/nvim"
    else
      echo -e "${yellowColour}    [!] Ya existe $rutaP/.config/nvim, se omite la clonación....${endColour}"
    fi

    cp -r "$rutaT/kitty" "$rutaP/.config"
    sudo cp -r "$rutaT/kitty" /root/.config

    sudo cp -r "$rutaT/fonts/"* /usr/share/fonts
    sudo fc-cache -fv

    cp -r "$rutaT/picom" "$rutaP/.config"

    sudo mkdir -p /usr/share/zsh-sudo/

    sudo wget -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh &>/dev/null

    sudo systemctl enable open-vm-tools.service || echo -e "${yellowColour}[!] No se pudo habilitar open-vm-tools.service, se continúa....${endColour}"
    sudo systemctl enable docker.service || echo -e "${yellowColour}[!] No se pudo habilitar docker.service, se continúa....${endColour}"

    cd

    if [ ! -d "$HOME/powerlevel10k" ]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe ~/powerlevel10k, se omite la clonación....${endColour}"
    fi

    rm -rf "$rutaP/.p10k.zsh"
    rm -rf "$rutaP/.zshrc"

    cp "$rutaT/files/.zshrc" "$HOME"
    cp "$rutaT/files/.p10k.zsh" "$HOME"

    sudo touch /root/.zshrc

    if ! sudo test -d /root/powerlevel10k; then
      sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe /root/powerlevel10k, se omite la clonación....${endColour}"
    fi

    sudo rm -rf /root/.p10k.zsh
    sudo rm -rf /root/.zshrc

    sudo cp "$rutaT/files_root/.zshrc" /root
    sudo cp "$rutaT/files_root/.p10k.zsh" /root

    sudo cp -r "$rutaT/kitty" /root/.config/

    rm -rf "$HOME/.config/polybar/"
    cp -r "$rutaT/polybar" "$HOME/.config"
    cp -r "$rutaT/rofi" "$rutaP/.config"
    chmod +x "$rutaP/.config/rofi/bin/"*

    # Dark theme and icons (no fatales: en Kali puede no haber sesión GNOME activa)
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

    # Variables globales idempotentes (sin duplicar en cada ejecución)
    for lineaEnv in "QT_QPA_PLATFORMTHEME=gtk3" "GTK_THEME=Arc-Dark"; do
      if ! sudo grep -qxF "${lineaEnv}" /etc/environment; then
        echo "${lineaEnv}" | sudo tee -a /etc/environment >/dev/null
      fi
    done

    mkdir -p ~/.config/gtk-4.0
    tee ~/.config/gtk-4.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
EOF

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
