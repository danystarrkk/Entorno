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
  echo -e "\n${redColour}[!] Saliendo...${endColour}\n"
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

  echo -e "\n\t ${blueColour} Instalación del Entorno (Optimizada para Docker) \n\n${endColour}"

  echo -en "${turquoiseColour}[1] Instalar dependencias [y/n]: ${endColour}" && read opt1
  opt1="${opt1:-n}"

  if [[ "$opt1" == "y" ]]; then
    echo -e "\n${purpleColour}    [+] Instalando Dependencias Base......${endColour}"

    sudo apt update -y && sudo apt upgrade -y

    # Fuentes (fonts-ubuntu fuera: no existe en kali-rolling y ninguna config la usa)
    sudo apt install -y fonts-dejavu fonts-liberation fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-noto-extra fonts-roboto fonts-open-sans

    # S2: lista verificada contra el indice binario oficial de kali-rolling.
    # wmname fuera (no existe en kali-rolling y aqui no hay bspwmrc).
    # libgl1-mesa-dri/libglx-mesa0: GL de Mesa para kitty y apps GTK con GPU
    # passthrough (--device /dev/dri) — analogo del S11 de main en contenedor.
    # S7 (GPU real por tunel): libvulkan1 + vulkan-tools + mesa-va-drivers;
    # los drivers NVIDIA proprietary NO van aqui (kernel = host, toolkit).
    sudo apt install -y dconf-cli libglib2.0-bin papirus-icon-theme mesa-opencl-icd ocl-icd-libopencl1 librsvg2-common shared-mime-info mesa-vulkan-drivers intel-media-va-driver adwaita-icon-theme libcanberra-gtk3-module xdg-desktop-portal xdg-desktop-portal-gtk gvfs gvfs-common thunar xclip xsel neovim zsh-syntax-highlighting bat lsd npm libglib2.0-dev ripgrep unzip wget git curl xdg-user-dirs libgl1-mesa-dri libglx-mesa0 libvulkan1 vulkan-tools mesa-va-drivers

    echo -e "${greenColour}    [+] Instalación de dependencias correctamente.....${endColour}"

  else
    echo -e "\n\t${redColour}[!] No se instalarán las dependencias, no se recomienda omitir este paso...  ${endColour}"
  fi

}

function configuracionEntorno() {

  echo -en "\n${blueColour}[2] Desea configurar el Entorno [y/n]:${endColour}" && read opt1
  opt1="${opt1:-n}"

  if [[ "$opt1" == "y" ]]; then

    echo -e "\n${turquoiseColour}[+] Configuración del Entorno: ${endColour}"

    # 1. Fuentes Nerd Fonts (S5: anti-duplicados — sin re-descarga si ya están)
    echo -e "${purpleColour}    [+] Descargando e instalando fuentes...${endColour}"
    if [ -n "$(ls -A "$rutaT/fonts/HackNerdFonts" 2>/dev/null)" ]; then
      echo -e "${yellowColour}    [!] Ya están las fuentes HackNerdFonts, se omite la descarga....${endColour}"
    else
      wget -q -P "$rutaT" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
      mkdir -p "$rutaT/fonts/HackNerdFonts"
      unzip -q -o "$rutaT/Hack.zip" -d "$rutaT/fonts/HackNerdFonts"
      rm -rf "$rutaT/Hack.zip"
    fi

    if [ -n "$(ls -A "$rutaT/fonts/JetBrainsMono" 2>/dev/null)" ]; then
      echo -e "${yellowColour}    [!] Ya están las fuentes JetBrainsMono, se omite la descarga....${endColour}"
    else
      wget -q -P "$rutaT" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
      mkdir -p "$rutaT/fonts/JetBrainsMono"
      unzip -q -o "$rutaT/JetBrainsMono.zip" -d "$rutaT/fonts/JetBrainsMono"
      rm -rf "$rutaT/JetBrainsMono.zip"
    fi

    # S5: copiar fuentes al sistema solo si no están
    if [ -d /usr/share/fonts/HackNerdFonts ]; then
      echo -e "${yellowColour}    [!] Ya están las fuentes en /usr/share/fonts, se omite la copia....${endColour}"
    else
      sudo cp -r "$rutaT/fonts/"* /usr/share/fonts
      sudo fc-cache -fv &>/dev/null
    fi

    # 2. Configuración de utilidades base (.config) y XDG Dirs
    echo -e "${purpleColour}    [+] Estructurando directorios de configuración y usuario...${endColour}"
    mkdir -p "$rutaP/.config"
    sudo mkdir -p /root/.config

    # Forzar la creación de las carpetas XDG para el usuario actual y root
    xdg-user-dirs-update
    sudo xdg-user-dirs-update

    cp -r "$rutaT/kitty" "$rutaP/.config/"
    sudo cp -r "$rutaT/kitty" /root/.config/

    # S3: Neovim externo — solo usuario, guardado
    if [ ! -d "$rutaP/.config/nvim" ]; then
      git clone --depth=1 https://github.com/danystarrkk/nvim "$rutaP/.config/nvim"
    else
      echo -e "${yellowColour}    [!] Ya existe $rutaP/.config/nvim, se omite la clonación....${endColour}"
    fi

    # 3. Zsh y Powerlevel10k (S5: guardas anti-duplicados)
    echo -e "${purpleColour}    [+] Configurando Zsh y P10k...${endColour}"
    sudo mkdir -p /usr/share/zsh-sudo/
    if [ -f /usr/share/zsh-sudo/sudo.plugin.zsh ]; then
      echo -e "${yellowColour}    [!] Ya existe el plugin sudo de zsh, se omite la descarga....${endColour}"
    else
      sudo wget -q -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
    fi

    if [ ! -d "$HOME/powerlevel10k" ]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe ~/powerlevel10k, se omite la clonación....${endColour}"
    fi

    if ! sudo test -d /root/powerlevel10k; then
      sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe /root/powerlevel10k, se omite la clonación....${endColour}"
    fi

    rm -rf "$rutaP/.p10k.zsh" "$rutaP/.zshrc"
    sudo rm -rf /root/.p10k.zsh /root/.zshrc

    cp "$rutaT/files/.zshrc" "$HOME"
    cp "$rutaT/files/.p10k.zsh" "$HOME"

    sudo cp "$rutaT/files_root/.zshrc" /root
    sudo cp "$rutaT/files_root/.p10k.zsh" /root

    # 4. FZF (S5: clones guardados)
    echo -e "${purpleColour}    [+] Instalando FZF...${endColour}"
    if [ ! -d "$HOME/.fzf" ]; then
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe ~/.fzf, se omite la clonación....${endColour}"
    fi
    ~/.fzf/install --all &>/dev/null

    if ! sudo test -d /root/.fzf; then
      sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf &>/dev/null
    else
      echo -e "${yellowColour}    [!] Ya existe /root/.fzf, se omite la clonación....${endColour}"
    fi
    sudo /root/.fzf/install --all &>/dev/null

    # 5. Tema Orchis Dark Compact (S5: rm previo — en re-run el clone fallaba
    #    porque el destino ya existía; el install se re-ejecuta = refresh)
    echo -e "${blueColour}[+] Instalando y aplicando tema Orchis-Dark-Compact...${endColour}"
    rm -rf /tmp/Orchis-theme
    git clone https://github.com/vinceliuice/Orchis-theme.git /tmp/Orchis-theme &>/dev/null
    /tmp/Orchis-theme/install.sh -t all -c compact -s standard --tweaks solid &>/dev/null
    rm -rf /tmp/Orchis-theme

    # gsettings con guarda: en el contenedor puede no haber DBus listo
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &>/dev/null || echo -e "${yellowColour}[!] gsettings 'prefer-dark' no disponible (sin DBus), se continúa....${endColour}"
    gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark-Compact' &>/dev/null || echo -e "${yellowColour}[!] gsettings 'Orchis-Dark-Compact' no disponible, se continúa....${endColour}"
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' &>/dev/null || echo -e "${yellowColour}[!] gsettings 'Papirus-Dark' no disponible, se continúa....${endColour}"

    # 6. Forzar configuración GTK por archivos (tee sobrescribe = sin duplicados)
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

    # 7. Variables de entorno globales para GTK/QT (S5: idempotente — antes el
    #    tee -a duplicaba las dos líneas en cada corrida)
    for lineaEnv in "QT_QPA_PLATFORMTHEME=gtk3" "GTK_THEME=Orchis-Dark-Compact"; do
      if ! sudo grep -qxF "${lineaEnv}" /etc/environment; then
        echo "${lineaEnv}" | sudo tee -a /etc/environment >/dev/null
      fi
    done

    # 8. GPU real del host vía túnel/passthrough (S7): diagnóstico y grupos
    echo -e "${blueColour}[+] Verificando acceso a la GPU real del host...${endColour}"
    if [ -d /dev/dri ]; then
      echo -e "${greenColour}    [+] /dev/dri disponible (passthrough activo): $(ls /dev/dri | tr '\n' ' ')${endColour}"
      for grpGpu in video render; do
        if getent group "$grpGpu" >/dev/null; then
          sudo usermod -aG "$grpGpu" "$USER" || echo -e "${yellowColour}[!] No se pudo agregar al grupo $grpGpu, se continúa....${endColour}"
        fi
      done
      if command -v vulkaninfo >/dev/null 2>&1; then
        if vulkaninfo >/dev/null 2>&1; then
          echo -e "${greenColour}    [+] Vulkan detecta la GPU real (vulkaninfo OK)${endColour}"
        else
          echo -e "${yellowColour}    [!] vulkaninfo no ve GPU: revisa el túnel (ICD / --device /dev/dri)....${endColour}"
        fi
      fi
    else
      echo -e "${yellowColour}    [!] Sin /dev/dri: ejecuta el contenedor con --device /dev/dri (y --gpus all / nvidia-container-toolkit si la tarjeta es NVIDIA)....${endColour}"
    fi

    # Con set -e, llegar hasta aquí significa que no hubo errores fatales
    echo -e "\n${greenColour}[+] Se completó la configuración del Entorno.... ${endColour}"
  else
    echo -e "${redColour}\n\t[!] Configuración del Entorno Cancelada...\n\n${endColour}"
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

echo -e "${greenColour}[*] Script finalizado. Por favor, reinicia tu terminal (exit y vuelve a ejecutar 'pentest').${endColour}"
