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
  echo -e "\n${redColour}[!] Saliendo...${endColour}\n"
  exit 1
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

  echo -e "\n\t ${blueColour} Instalación del Entorno (Optimizada para Docker) \n\n${endColour}"

  echo -en "${turquoiseColour}[1] Instalar dependencias [y/n]: ${endColour}" && read opt1

  if [ "$opt1" == "y" ]; then
    echo -e "\n${purpleColour}    [+] Instalando Dependencias Base......${endColour}"

    sudo apt update -y && sudo apt upgrade -y

    sudo apt install -y fonts-dejavu fonts-liberation fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-noto-extra fonts-ubuntu fonts-roboto fonts-open-sans

    sudo apt install -y dconf-cli libglib2.0-bin papirus-icon-theme pocl-opencl-icd xclip xsel neovim zsh-syntax-highlighting bat lsd npm wmname libglib2.0-dev ripgrep unzip wget git curl

    if [ $? -eq 0 ]; then
      echo -e "${greenColour}    [+] Instalación de dependencias correctamente.....${endColour}"
    else
      echo -e "${redColour}    [!] Error en la Instalación de Dependencias....${endColour}"
    fi

  else
    echo -e "\n\t${redColour}[!] No se instalarán las dependencias, no se recomienda omitir este paso...  ${endColour}"
  fi

}

function configuracionEntorno() {

  echo -en "\n${blueColour}[2] Desea configurar el Entorno [y/n]:${endColour}" && read opt1

  if [ "$opt1" == "y" ]; then

    echo -e "\n${turquoiseColour}[+] Configuración del Entorno: ${endColour}"

    # 1. Fuentes Nerd Fonts
    echo -e "${purpleColour}    [+] Descargando e instalando fuentes...${endColour}"
    wget -q -P $rutaT https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    mkdir -p $rutaT/fonts/HackNerdFonts
    unzip -q $rutaT/Hack.zip -d $rutaT/fonts/HackNerdFonts
    rm -rf $rutaT/Hack.zip

    wget -q -P $rutaT https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    mkdir -p $rutaT/fonts/JetBrainsMono
    unzip -q -o $rutaT/JetBrainsMono.zip -d $rutaT/fonts/JetBrainsMono
    rm -rf $rutaT/JetBrainsMono.zip

    sudo cp -r $rutaT/fonts/* /usr/share/fonts
    sudo fc-cache -fv &>/dev/null

    cp -r $rutaT/kitty $rutaP/.config
    sudo cp -r $rutaT/kitty /root/.config

    echo -e "${purpleColour}    [+] Configurando Zsh y P10k...${endColour}"
    sudo mkdir -p /usr/share/zsh-sudo/
    sudo wget -q -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k &>/dev/null
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k &>/dev/null

    rm -rf $rutaP/.p10k.zsh $rutaP/.zshrc
    sudo rm -rf /root/.p10k.zsh /root/.zshrc

    cp $rutaT/files/.zshrc $HOME
    cp $rutaT/files/.p10k.zsh $HOME

    sudo cp $rutaT/files_root/.zshrc /root
    sudo cp $rutaT/files_root/.p10k.zsh /root
    sudo ln -s -f $rutaP/.zshrc /root/.zshrc

    echo -e "${purpleColour}    [+] Instalando FZF...${endColour}"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
    ~/.fzf/install --all &>/dev/null

    sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf &>/dev/null
    sudo /root/.fzf/install --all &>/dev/null

    echo -e "${blueColour}[+] Instalando y aplicando tema Orchis-Dark-Compact...${endColour}"
    git clone https://github.com/vinceliuice/Orchis-theme.git /tmp/Orchis-theme &>/dev/null
    /tmp/Orchis-theme/install.sh -t all -c compact -s standard --tweaks solid &>/dev/null
    rm -rf /tmp/Orchis-theme

    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &>/dev/null
    gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark-Compact' &>/dev/null
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' &>/dev/null

    mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
    sudo mkdir -p /root/.config/gtk-3.0 /root/.config/gtk-4.0

    tee ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Orchis-Dark-Compact
gtk-icon-theme-name=Papirus-Dark
EOF

    sudo tee /root/.config/gtk-3.0/settings.ini /root/.config/gtk-4.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Orchis-Dark-Compact
gtk-icon-theme-name=Papirus-Dark
EOF

    # 7. Variables de entorno globales para GTK/QT
    sudo tee -a /etc/environment >/dev/null <<'EOF'
QT_QPA_PLATFORMTHEME=gtk3
GTK_THEME=Orchis-Dark-Compact
EOF

    if [ $? -eq 0 ]; then
      echo -e "\n${greenColour}[+] Se completó la configuración del Entorno.... ${endColour}"
    else
      echo -e "\n${redColour}[!] Error en la configuración del Entorno....${endColour}"
    fi
  else
    echo -e "${redColour}\n\t[!] Configuración del Entorno Cancelada...\n\n${endColour}"
  fi

}

##### Orden de Ejecución #########
installDependencias
configuracionEntorno

echo -e "${greenColour}[*] Script finalizado. Por favor, reinicia tu terminal (exit y vuelve a ejecutar 'pentest').${endColour}"
