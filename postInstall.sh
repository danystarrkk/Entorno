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
rutaT="$HOME/Downloads/Entorno/configs"
rutaE="$HOME/Downloads/Entorno/"

################################

############## Funciones Globales #############

function installDependencias() {

  clear

  echo -e "\n\t ${blueColour} Instalación del Entorno \n\n${endColour}"

  echo -en "${turquoiseColour}[1] Instalar dependencias [y/n]: ${endColour}" && read opt1

  if [ $opt1 == "y" ]; then
    echo -e "\n${purpleColour}    [+] Instalando Dependencias......${endColour}"

    sudo pacman -Syu

    sudo pacman -S --needed base-devel git -y &>/dev/null

    echo -e "${blueColour}[+] Instalando yay ${endColour}\n"

    git clone https://aur.archlinux.org/yay.git

    mv yay configs
    cd $rutaT/yay
    makepkg -si
    cd $rutaE

    yay -S net-tools flameshot xclip xsel neovim xorg-xsetroot git vim zsh bspwm sxhkd picom polybar rofi feh kitty zsh-syntax-highlighting bat lsd npm open-vm-tools wmname dash glib2-devel gtkmm3 firefox docker docker-compose unzip sddm wget curl arandr nitrogen firefox

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

    wget -P $rutaT wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    unzip $rutaT/Hack.zip -d $rutaT/fonts
    rm -rf $rutaT/Hack.zip

    mkdir $rutaP/.config/bin
    touch $rutaP/.config/bin/target

    cp -r $rutaT/bspwm $rutaP/.config
    cp -r $rutaT/sxhkd $rutaP/.config

    chsh -s /bin/zsh
    sudo chsh -s /bin/zsh

    chmod +x $HOME/.config/bspwm/scripts/*

    cp -r $rutaT/wallpapers $rutaP/Pictures
    cp -r $rutaT/nvim $rutaP/.config

    cp -r $rutaT/kitty $rutaP/.config
    sudo cp -r $rutaT/kitty /root/.config

    sudo cp $rutaT/fonts/* /usr/share/fonts

    cp -r $rutaT/picom $rutaP/.config

    sudo mkdir /usr/share/zsh-sudo/

    sudo wget -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh &>/dev/null
    sudo systemctl enable vmtoolsd.service
    sudo systemctl enable vmware-vmblock-fuse.service
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

    echo -e "${blueColour}[+] Instalando SDDM mínimo...${endColour}"

    # Habilitar el servicio de SDDM
    sudo systemctl enable sddm.service

    # Crear archivo de sesión para bspwm
    sudo tee /usr/share/xsessions/bspwm.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary space partitioning window manager
Exec=bspwm
Type=Application
EOF

    cd
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    sudo cd
    sudo git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    sudo ~/.fzf/install

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

installDependencias
configuracionEntorno
