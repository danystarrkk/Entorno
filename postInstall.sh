#!/usr/bin/bash

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
}

trap ctrl_c SIGINT

#########################

####### Varibles Globales ######

rutaP="$HOME"
rutaT="$HOME/Entorno/configs"
rutaE="$HOME/Entorno/"

################################

############## Funciones Globales #############

function installDependencias() {

  clear

  echo -e "\n\t ${blueColour} Instalación del Entorno \n\n${endColour}"

  echo -en "${turquoiseColour}[1] Instalar dependencias [y/n]: ${endColour}" && read opt1

  if [ $opt1 == "y" ]; then
    echo -e "\n${purpleColour}    [+] Instalando Dependencias......${endColour}"

    sudo apt update -y && sudo apt upgrade -y

    sudo apt install -y fonts-dejavu fonts-liberation fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-noto-extra fonts-ubuntu fonts-roboto fonts-open-sans

    sudo apt install -y dconf-cli libglib2.0-bin arc-theme papirus-icon-theme flameshot pocl-opencl-icd xclip xsel neovim x11-xserver-utils bspwm sxhkd picom polybar rofi feh kitty zsh-syntax-highlighting bat lsd npm wmname libglib2.0-dev docker.io docker-compose arandr ripgrep qemu-guest-agent spice-vdagent

    if [ $(echo $?) -eq 0 ]; then
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

  if [ $opt1 == "y" ]; then

    echo -e "\n${turquoiseColour}[+] Configuración del Entorno: ${endColour}"

    wget -P $rutaT https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    mkdir -p $rutaT/fonts/HackNerdFonts
    unzip $rutaT/Hack.zip -d $rutaT/fonts/HackNerdFonts
    rm -rf $rutaT/Hack.zip

    wget -P $rutaT https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    mkdir -p $rutaT/fonts/JetBrainsMono
    unzip -o $rutaT/JetBrainsMono.zip -d $rutaT/fonts/JetBrainsMono
    rm -rf $rutaT/JetBrainsMono.zip

    mkdir $rutaP/.config/bin
    touch $rutaP/.config/bin/target

    cp -r $rutaT/bspwm $rutaP/.config
    cp -r $rutaT/sxhkd $rutaP/.config

    chsh -s /bin/zsh
    sudo chsh -s /bin/zsh

    chmod +x $HOME/.config/bspwm/scripts/*

    cp -r $rutaT/wallpapers $rutaP/Imágenes
    cp -r $rutaT/nvim $rutaP/.config

    cp -r $rutaT/kitty $rutaP/.config
    sudo cp -r $rutaT/kitty /root/.config

    sudo cp -r $rutaT/fonts/* /usr/share/fonts
    sudo fc-cache -fv

    cp -r $rutaT/picom $rutaP/.config

    sudo mkdir /usr/share/zsh-sudo/

    sudo wget -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh &>/dev/null
    sudo systemctl enable qemu-guest-agent.service
    sudo systemctl enable spice-vdagentd.service
    sudo systemctl enable docker.service

    cd

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k &>/dev/null

    rm -rf $rutaP/.p10k.zsh
    rm -rf $rutaP/.zshrc

    cp $rutaT/files/.zshrc $HOME
    cp $rutaT/files/.p10k.zsh $HOME
    cp $rutaT/files/.gitconfig $HOME

    sudo touch /root/.zshrc

    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k &>/dev/null

    sudo rm -rf /root/.p10k.zsh
    sudo rm -rf /root/.zshrc

    sudo cp $rutaT/files_root/.zshrc /root
    sudo cp $rutaT/files_root/.p10k.zsh /root

    sudo cp -r $rutaT/kitty /root/.config/
    sudo cp -r $rutaT/nvim /root/.config/

    sudo ln -s -f $rutaP/.zshrc /root/.zshrc

    rm -rf ~/.config/polybar/
    cp -r $rutaT/polybar $HOME/.config
    cp -r $rutaT/rofi $rutaP/.config

    # Dark theme and icons
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

    mkdir -p ~/.config/gtk-3.0

    tee ~/.config/gtk-3.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
EOF

    cd
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all

    sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
    sudo /root/.fzf/install --all

    echo -e "${blueColour}[+] Aplicando variables globales para Tema Oscuro...${endColour}"

    # 1. Forzar a las aplicaciones Qt a usar el motor de GTK3 y tu tema
    sudo tee -a /etc/environment >/dev/null <<'EOF'
QT_QPA_PLATFORMTHEME=gtk3
GTK_THEME=Arc-Dark
EOF

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

    if [ $(echo $?) -eq 0 ]; then
      echo -e "\n${greenColour}[+] Se completo la configuración del Entorno.... ${endColour}"
    else
      echo -e "\n${redColour}[!] Error en la configuración del Entorno....${endColour}"
    fi
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
