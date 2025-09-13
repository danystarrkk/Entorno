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

    yay -S net-tools flameshot xclip xsel neovim xorg-xsetroot git vim zsh bspwm sxhkd picom polybar rofi feh kitty zsh-syntax-highlighting bat lsd npm open-vm-tools wmname dash glib2-devel gtkmm3 firefox docker docker-compose unzip lightdm lightdm-webkit2-greeter lightdm-webkit-theme-glorious

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

    echo -e "${blueColour}[+] Configurando LightDM con tema Glorious...${endColour}"

    # Habilitar el servicio de LightDM
    sudo systemctl enable lightdm.service

    # Configurar LightDM para usar el greeter webkit2
    sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf

    # Configurar el tema Glorious
    sudo sed -i 's/^#webkit-theme\s*=\s*$/webkit-theme = glorious/' /etc/lightdm/lightdm-webkit2-greeter.conf
    sudo sed -i 's/^#webkit-mode\s*=\s*$/webkit-mode = light/' /etc/lightdm/lightdm-webkit2-greeter.conf

    # Configurar para auto-detectar usuario
    sudo sed -i 's/^#remember-user\s*=\s*$/remember-user = true/' /etc/lightdm/lightdm.conf

    # Crear archivo de sesión para bspwm
    sudo tee /usr/share/xsessions/bspwm.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary space partitioning window manager
Exec=bspwm
Type=Application
Icon=bspwm
EOF

    # Configurar sesión por defecto (opcional - puede elegirse desde el greeter)
    sudo sed -i 's/^#user-session\s*=\s*$/user-session=bspwm/' /etc/lightdm/lightdm.conf

    # Configurar fondo de pantalla del login (opcional)
    sudo sed -i 's/^#background\s*=\s*$/background=\/usr\/share\/backgrounds\/archlinux\/arch-wallpaper.jpg/' /etc/lightdm/lightdm.conf

    # Crear directorio de backgrounds si no existe
    sudo mkdir -p /usr/share/backgrounds/archlinux

    # Descargar un wallpaper por defecto para LightDM
    sudo curl -o /usr/share/backgrounds/archlinux/arch-wallpaper.jpg https://raw.githubusercontent.com/archlinux/artwork/master/wallpapers/archlinux/arch-wallpaper.jpg

    # Configurar para que se muestre el selector de sesiones
    sudo sed -i 's/^#show-desktoppicker\s*=\s*$/show-desktoppicker=true/' /etc/lightdm/lightdm-webkit2-greeter.conf

    # Ajustar permisos
    sudo chmod 755 /etc/lightdm/lightdm.conf
    sudo chmod 755 /etc/lightdm/lightdm-webkit2-greeter.conf

    echo -e "${greenColour}[+] LightDM configurado con tema Glorious${endColour}"
    echo -e "${yellowColour}[*] Tema: Glorious (modo claro)${endColour}"
    echo -e "${yellowColour}[*] Sesiones disponibles: bspwm${endColour}"
    echo -e "${yellowColour}[*] Recordar usuario: Activado${endColour}"

    echo -e "${blueColour}[+] Configurando Kali Linux en Docker...${endColour}"

    # Instalar Docker si no está instalado
    if ! command -v docker &>/dev/null; then
      echo -e "${blueColour}[+] Instalando Docker...${endColour}"
      sudo pacman -S --noconfirm docker docker-compose
      sudo systemctl enable docker.service
      sudo systemctl start docker.service
    fi

    # Crear directorio para análisis
    cd
    mkdir -p ~/kali-analysis/{binaries,samples,reports,scripts}
    cd ~/kali-analysis

    # Crear Dockerfile personalizado para Kali
    cat >Dockerfile <<'EOF'
FROM kalilinux/kali-rolling

# Actualizar e instalar herramientas de análisis
RUN apt update && apt full-upgrade -y

# Herramientas esenciales de análisis
RUN apt install -y \
    gdb \
    gef \
    pwndbg \
    radare2 \
    cutter \
    strace \
    ltrace \
    binutils \
    file \
    binwalk \
    foremost \
    yara \
    clamav \
    upx-ucl \
    pev \
    wine \
    wine32 \
    python3-pip \
    python3-keystone \
    python3-capstone \
    python3-unicorn \
    checksec \
    patchelf

# Herramientas de reversing
RUN apt install -y \
    john \
    hashcat \
    hydra \
    nmap \
    wireshark \
    tcpdump

# Limpiar cache
RUN apt autoremove -y && apt clean

# Crear usuario para análisis
RUN useradd -m -s /bin/bash analyst
WORKDIR /home/analyst
USER analyst

CMD ["/bin/bash"]
EOF

    # Crear script de lanzamiento
    cat >kali-analysis.sh <<'EOF'
#!/bin/bash
# Script para ejecutar Kali Docker con montaje de directorios

ANALYSIS_DIR="$HOME/kali-analysis"

docker build -t kali-analysis .
docker run -it --rm \
    --name kali-analysis \
    --hostname kali-analysis \
    -v $ANALYSIS_DIR/binaries:/home/analyst/binaries \
    -v $ANALYSIS_DIR/samples:/home/analyst/samples \
    -v $ANALYSIS_DIR/reports:/home/analyst/reports \
    -v $ANALYSIS_DIR/scripts:/home/analyst/scripts \
    --network host \
    --cap-add=NET_RAW \
    --cap-add=NET_ADMIN \
    kali-analysis
EOF

    chmod +x kali-analysis.sh

    # Crear script de análisis rápido
    cat >scripts/quick-analysis.sh <<'EOF'
#!/bin/bash
echo "=== KALI QUICK ANALYSIS ==="
echo "File: $1"
echo "Size: $(du -h "$1" | cut -f1)"
echo "Type: $(file "$1")"
echo "MD5: $(md5sum "$1" | cut -d' ' -f1)"
echo "SHA256: $(sha256sum "$1" | cut -d' ' -f1)"
echo ""
echo "=== STRINGS ==="
strings "$1" | head -20
echo ""
echo "=== CHECKSEC ==="
checksec --file="$1"
EOF

    chmod +x scripts/quick-analysis.sh

    echo -e "${greenColour}[+] Configuración completada!${endColour}"
    echo -e "${blueColour}[+] Para usar Kali Docker:${endColour}"
    echo -e "  ${greenColour}1. Construir imagen: ${endColour}cd ~/kali-analysis && docker build -t kali-analysis ."
    echo -e "  ${greenColour}2. Ejecutar: ${endColour}./kali-analysis.sh"
    echo -e "  ${greenColour}3. Colocar binarios en: ${endColour}~/kali-analysis/binaries/"
    echo -e "  ${greenColour}4. Los reports se guardan en: ${endColour}~/kali-analysis/reports/"

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
