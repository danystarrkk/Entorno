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
rutaT="$HOME/Descargas/Entorno/configs"

################################

############## Funciones Globales #############

function installDependencias() {

  clear

  echo -e "\n\t ${blueColour} Instalación del Entorno \n\n${endColour}"

  echo -en "${turquoiseColour}[1] Instalar dependencias [y/n]: ${endColour}" && read opt1

  if [ $opt1 == "y" ]; then
    echo -e "\n${purpleColour}    [+] Instalando Dependencias......${endColour}"

    sudo dnf install xsetroot google-chrome-stable git vim zsh bspwm sxhkd picom polybar rofi feh kitty zsh-syntax-highlighting bat lsd npm ImageMagick -y

    if [ $(echo $?) -eq 0 ]; then
      echo -e "${greenColour}    [+] Instalación de dependecias correctamente.....${endColour}"
    else
      echo -e "${redColour}    [!] Error en la Instalación de Dependencias....${endColour}"

    fi

  else
    echo -e "\n${redColour}    [!] No se instalaran las dependecias, no se recomienda omitir este paso...  ${endColour}"
  fi

}

function configuracionEntorno() {

  echo -e "\n${turquoiseColour}[2] Configuración del Entorno: ${endColour}"

  cp -r $rutaT/bspwm $rutaP/.config
  cp -r $rutaT/sxhkd $rutaP/.config

  chmod +x $HOME/.config/bspwm/scripts/*

  mkdir $rutaP/Imágenes/.wallpaper
  cp $rutaT/wallpaper/fondo.png $rutaP/Pictures/.wallpaper

  cp -r $rutaT/kitty $rutaP/.config
  sudo cp -r $rutaT/kitty /root/.config

  sudo cp $rutaT/fonts/* /usr/share/fonts

  cp -r $rutaT/picom $rutaP/.config

  sudo mkdir /usr/share/zsh-sudo/

  sudo wget -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh &>/dev/null

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

  rofi-theme-selector &>/dev/null

  if [ $(echo $?) -eq 0 ]; then
    echo -e "\n${greenColour}    [+] Se completo la configuración del Entorno.... ${endColour}"
  else
    echo -e "\n${redColour}    [!] Error en la configuración del Entorno....${endColour}"
  fi

}

##### Orden de Ejecución #########

installDependencias
configuracionEntorno
