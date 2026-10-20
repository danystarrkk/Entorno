# Feature: kali-configs — overhaul de script y configs rama main (Kali Linux)

Rama `main` (base 1a9fd56). Port a Kali Linux del overhaul aplicado en la rama `arch`
(feature `odd/tasks/arch-configs.md`, commit 670dd79): paquetes, robustez, configs
optimizadas para VMware (glx+blur), nvim externo. Sin push (los hace el usuario).

## Specs

S1 — Neovim externo
Cita usuario (feature arch): "vamos a eliminar lo referente a neovim tanto en el script
como en la carpeta si clonara directamente nvim del repo https://github.com/danystarrkk/nvim"
- Borrar configs/nvim/ del repo completo.
- postInstall.sh: quitar `cp -r $rutaT/nvim ...` (usuario y root); reemplazar por
  `git clone --depth=1 https://github.com/danystarrkk/nvim ~/.config/nvim` (solo usuario;
  sin nvim para root). Guardar si el directorio ya existe.

S2 — Paquetes apt (equivalente Kali del S2-arch)
- Agregar a la transacción apt: maim dunst libnotify-bin xdotool alsa-utils viewnior
  i3lock-fancy mpc mpd x11-xkb-utils. `x11-xserver-utils` (xrandr) ya está en la lista.
- Verificado en pkg.kali.org (kali-rolling): maim 5.8.0-1.1, dunst 1.13.2-1, xdotool,
  i3lock-fancy 0.0~git20160228, mpc 0.35-1, mpd 0.24.12-1, viewnior — todos existen.
  `x11-xkb-utils` es el paquete Debian que provee setxkbmap.
- mpd va junto a mpc: powermenu ejecuta `mpc -q pause` y sin mpd el comando es inútil.
- No hay AUR/yay ni BlackArch en Kali: NO crear transacciones extra ni scripts de
  repositorio; las herramientas pentest (whatweb ffuf wfuzz burpsuite seclists) ya
  vienen con Kali y el script no las instala.
- Conservar las líneas apt existentes, incluidos open-vm-tools y mesa-utils (fix de
  rendimiento 1a9fd56).

S3 — Robustez de postInstall.sh (mismo alcance que arch)
- `set -Eeuo pipefail`, trap ERR con línea+comando, ctrl_c sale con código 130.
- Prompts: manejar input vacío; test con `[[ "$opt1" == "y" ]]` (comillas).
- `mkdir -p`, `unzip -o`, `git clone` guardado (skip si ya existe el dir).
- /etc/environment idempotente (grep -q antes de append).
- rutas derivadas de la ubicación del script (BASH_SOURCE), no de ~/Entorno.
- Eliminar `cp $rutaT/files/.gitconfig` (el archivo no existe en el repo).
- Agregar `chmod +x` de configs/rofi/bin/* tras copiar rofi (hoy 644 en git y sxhkd
  los ejecuta).
- systemctl enable (open-vm-tools/docker) y gsettings: no fatales (aviso y continúa).
- Eliminar `sudo ln -s -f $rutaP/.zshrc /root/.zshrc` (pisa el .zshrc de root).

S4 — Picom glx + blur (decisión usuario, cita feature arch: "equilibrio perfecto entre
rendimiento en la maquina virtual que sera vmware y la personalizacion cosa como el blur
y sombras todo todo optimizalo sin quitarlo")
- Port de configs/picom/picom.conf de la rama arch (base aprobada): backend glx,
  blur-method dual_kawase, blur-size 5, blur-strength 3, vsync/use-damage/
  unredir-if-possible/glx-no-stencil, sombras ligeras, corner-radius 12, fading
  conservador, exclusiones de blur.
- Kali compatible: kali-rolling trae picom 13-1 (≥10, dual_kawase disponible),
  verificado en pkg.kali.org/pkg/picom.

S5 — Polybar
- Port de la rama arch: interval ethernet_status/vpn_status 2s→5s, target_status
  2s→10s; enable-ipc=true en [bar/top]; colors.ini con paleta fija (sin ${xrdb:color*});
  launch.sh sin `tee -a /tmp/polybar*.log`.

S6 — Kitty
- Port: `font_family HackNerdFont` → `font_family Hack Nerd Font` en kitty.conf.
- color.ini de main (actualización b830169) se conserva tal cual.

S7 — bspwmrc
- main ya usa feh con wallpaper propio (02. Solarized Dark.png) y ya tiene vmtoolsd /
  clipboard / xrandr / setxkbmap (commits 61f5f2e..f7bd997): NO copiar el fondo de
  arch ni tocar esas líneas.
- Sin cambios salvo lo que T5 verifique necesario.

S8 — root zshrc y zshrc usuario
- files_root/.zshrc: quitar `/opt/kitty/bin` y `/opt/nvim/bin` del PATH (Kali instala
  kitty y nvim vía apt en /usr/bin; esas rutas son mortales). Conservar el resto.
- NO aplicar el cambio de ruta de zsh-syntax-highlighting de arch
  (/usr/share/zsh/plugins/...): en Debian/Kali la ruta correcta es
  /usr/share/zsh-syntax-highlighting/... y main ya la tiene.
- files/.zshrc de main se conserva tal cual (batcat es el nombre del binario en Debian).

S9 — README
- Conservar README.md de main tal cual (no existe en arch).

S10 — Rofi
- Port de la rama arch (base aprobada en 5edd3d5): @theme relativo
  ("themes/catppuccin-*.rasi" — la ruta absoluta /home/stark/.local/share/rofi
  estaba rota), icon-theme "Papirus-Dark" y terminal "kitty" (los que instala
  el script), fuentes "JetBrainsMono Nerd Font" en todos los .rasi (las que
  descarga el installer), modos 755 en configs/rofi/bin/* (sxhkd los ejecuta;
  el script además hace chmod +x), iconos de tema genéricos (camera-photo,
  alarm) en screenshot y guards de command -v i3lock-fancy en powermenu
  (reemplaza tambien el $HOME/.local/bin/lock inexistente).

S11 — Controladores VMware (gráficos y lógicos)
Cita usuario: "verificame que tengamos los controladores graficos correctos tambien
recuerda que uso vmware para levantar esos entornos así que todo driver que ayude en
rendimiento grafico y logico es necesario."
- Agregar a la transacción apt: libgl1-mesa-dri libglx-mesa0 xserver-xorg-video-vmware.
- Verificado en kali-rolling (pkg.kali.org): mesa 26.1.6-1 (libgl1-mesa-dri y
  libglx-mesa0) y xserver-xorg-video-vmware 1:13.4.0-1.
- libgl1-mesa-dri: contiene vmwgfx_dri.so, el driver 3D de VMware (SVGA3D, hasta
  OpenGL 4.3 con Workstation 17); hoy solo llega como dependencia implícita.
- libglx-mesa0: proveedor GLX de Mesa — es lo que hace funcionar el backend
  "glx" de picom (S4).
- xserver-xorg-video-vmware: driver Xorg p/ VMware (KMS vía vmwgfx; fallback si
  el adaptador es "VMware SVGA" en vez de VMSVGA; arregla el auto-resize del bug
  Kali 0009441).
- Descartados tras investigación: xserver-xorg-input-vmmouse (no existe en
  Debian/Kali actual), mesa-va-drivers/mesa-vdpau-drivers (el huésped VMware no
  tiene motor de decodificación), mesa-opencl-icd (solo GPU AMD/Intel real).
- Ya presentes y confirmados: open-vm-tools + open-vm-tools-desktop (servicio
  habilitado, vmtoolsd/vmware-user-suid-wrapper en bspwmrc), mesa-utils,
  pocl-opencl-icd (OpenCL CPU), vmwgfx in-kernel.
- Fuera del repo (config lado VMware, aviso al usuario): Display → "Accelerate
  3D graphics" activado y adaptador de vídeo VMSVGA.

S12 — Filtros anti-duplicados (paquetes y configuración) orientados a Kali
Cita usuario: "listo vamos a generar los mismo filtros de seguridad para duplicados
en paquetes y en configuraciones en la rama de kali y orientado al kali."
- Paquetes/descargas: omitir wget/unzip de fuentes si configs/fonts/HackNerdFonts
  (o JetBrainsMono) no está vacío; copia a /usr/share/fonts + fc-cache solo si
  /usr/share/fonts/HackNerdFonts no existe; plugin sudo de zsh sin re-descarga si
  ya existe. Clones git ya guardados (nvim, p10k x2, fzf x2) y apt es
  naturalmente idempotente (re-instalar = no-op) → sin cambios ahí.
- Sin strap.sh/yay/BlackArch en Kali: no hay bootstrap que verificar.
- configuracionEntorno: quitar la copia DUPLICADA de kitty para root (2 en la
  misma corrida); quitar `sudo touch /root/.zshrc` (muerto: rm -rf le sigue);
  guardar la copia de wallpapers si $rutaP/Imágenes/wallpapers ya existe.
- Se REFRESCAN a propósito (sin guarda): copias de configs (bspwm, sxhkd, picom,
  kitty, polybar, rofi), rm+cp de .zshrc/polybar, settings gtk con tee — merge de
  cp -r no duplica y permite probar edits del repo re-ejecutando el script.

## Tasks

T1  S1-S3  postInstall.sh overhaul (nvim externo + paquetes apt + robustez)   inline   commit: 87d9fbe
T2  S4     picom.conf port de arch                                            inline   commit: 5eea7dc
T3  S5     polybar (colors/config/modules/launch) port de arch                inline   commit: 27acad2
T4  S6,S10  rofi port de arch (rutas/fuentes/powermenu/screenshot) + kitty    inline   commit: e425c07
T5  S1,S8  borrar configs/nvim + PATH files_root/.zshrc                       inline   commit: 39ec701
T6  S1-S9  verificación (bash -n, greps por spec) + docs + cierre             inline   commit: 01d8015 + cierre
T7  S11    drivers VMware gráficos en postInstall.sh                          inline   commit: d5896e4
T8  S12    filtros anti-duplicados paquetes+config                            inline   commit: pendiente

## Log

L1  "reviza engram y recuerda lo que trabajamos en este mismo repo una rama distinta
    pero para arch linux ahora lo mismo vamos a trabajar pero para kali linux"
L2  "lo mismo sobre el main directo pero ya sabes primero investigamos conocemos
    absolutamente todo y comenzamos con los mismos cambios pero orientados a kali
    en este caso."
L3  Verificación T6: bash -n postInstall.sh OK; zsh -n ambos .zshrc OK; bash -n
    de bspwmrc, rofi/bin/*, bspwm/scripts/*, polybar/launch.sh OK; picom/polybar/
    rofi/kitty.conf idénticos a arch (0 diff); bspwmrc, README, files/.zshrc y
    color.ini conservados de main (diff 1a9fd56..HEAD vacío); configs/nvim fuera
    de git; grep de nvim en script solo clon guardado. shellcheck no instalado
    en este host (no disponible).
L4  Decisión durante T1: /etc/environment mantiene solo las 2 variables de main
    (sin QT_STYLE_OVERRIDE=kvantum: la base 974cc2c lo tenía pero la migración Kali
    de main lo eliminó y kvantum no está en la lista apt). Decisión: no portar la
    sección SDDM de arch (Kali usa su propio display manager). mpd agregado junto
    a mpc porque powermenu ejecuta 'mpc -q pause'.
L5  Corrección de doc: los cambios de rofi no tenían spec propia; se agrega S10.
    El mensaje de e425c07 cita "(S4/S2/S6)": las referencias correctas son
    S10 (rofi) y S6 (kitty).
L6  "verificame que tengamos los controladores graficos correctos tambien
    recuerda que uso vmware para levantar esos entornos así que todo driver que
    ayude en rendimiento grafico y logico es necesario." → nueva spec S11 y task T7.
L7  "listo vamos a generar los mismo filtros de seguridad para duplicados en
    paquetes y en configuraciones en la rama de kali y orientado al kali." →
    nueva spec S12 y task T8 (port de arch-deps-fixes S3/S4 adaptado a apt/Kali).
