# Feature: docker-fixes — overhaul Kali orientado a Docker en la rama docker

Rama `docker` (tracking origin/docker, punta 21cde52, fork de main en f7bd997).
Análisis completo previo: nació como Docker en Arch y migró a Kali; conserva SOLO
configs/files/* (zshrc/p10k), configs/kitty/* y postInstall.sh (178 líneas) — sin
desktop (bspwm/picom/polybar/rofi/sxhkd/wallpapers/README). Se portan a esta rama
los mismos fixes de main (S1-S12) adaptados al entorno de contenedor.

## Specs

S1 — Robustez del script (port del S3-main)
- `set -Eeuo pipefail`, trap ERR con línea+comando, ctrl_c sale con 130 (hoy exit 1).
- Prompts con `opt1="${opt1:-n}"` y `[[ "$opt1" == "y" ]]`.
- rutas derivadas de BASH_SOURCE (hoy rutaT/rutaE hardcodeadas a ~/Entorno).
- Eliminar los dos `if [ $? -eq 0 ]` (incompatible con set -e; el trap ya reporta).
- sudo -v + bucle keep-alive (igual que main y arch).

S2 — Paquetes orientados a Docker (verificados contra el índice binario oficial
de kali-rolling: Packages.gz de http.kali.org, 71479 paquetes)
- Quitar `wmname`: NO existe en kali-rolling (además muerto aquí — no hay
  bspwmrc en esta rama; el equivalente main usa suckless-tools).
- Quitar `fonts-ubuntu` de la línea de fuentes (tampoco existe en
  kali-rolling — mismo hallazgo que el hotfix de main; ninguna config usa
  esa fuente).
- Agregar `libgl1-mesa-dri libglx-mesa0`: GL de Mesa para kitty y apps GTK vía
  passthrough de GPU (--device /dev/dri); es el análogo del S11-main aplicable
  al contenedor.
- NO aplican en contenedor (exclusiones documentadas): open-vm-tools* y
  xserver-xorg-video-vmware (pertenecen al host), BlackArch/yay/AUR (no existen
  en Kali), picom/polybar/rofi/bspwm (sin desktop; specs S4/S5/S7/S10-main sin
  objeto).
- El resto de la lista docker (31 paquetes): verificado OK contra el índice.
- Tema Orchis-Dark-Compact: decisión propia de esta rama — se conserva (main usa
  Arc-Dark). wireshark/docker.io quedaron fuera por decisión previa de la rama.

S3 — Neovim externo (port del S1-main)
Cita usuario (feature arch): "vamos a eliminar lo referente a neovim tanto en el
script como en la carpeta si clonara directamente nvim del repo
https://github.com/danystarrkk/nvim"
- git clone guardado de danystarrkk/nvim a ~/.config/nvim (hoy: neovim sin
  config; no hay copia de nvim que quitar y nada para root).

S4 — Kitty (port del S6-main)
- `font_family HackNerdFont` → `font_family Hack Nerd Font`.
- zshrc usuario y root: SIN CAMBIO (verificado: ruta Debian de
  zsh-syntax-highlighting ✓, aliases /usr/bin/batcat ✓, PATH sin /opt muertos ✓).

S5 — Filtros anti-duplicados (port del S12-main)
Cita usuario (feature kali): "listo vamos a generar los mismo filtros de seguridad
para duplicados en paquetes y en configuraciones en la rama de kali y orientado
al kali." → "corregir lo mismo que en el main kali solo que para docker."
- Fuentes Hack/JetBrains: sin re-descarga si ya descomprimidas; copia a
  /usr/share/fonts + fc-cache solo si falta HackNerdFonts.
- Plugin sudo de zsh: sin re-descarga si ya existe.
- p10k usuario y root, fzf usuario y root: clones guardados (hoy se re-clonan y
  fallan en cada re-run).
- Orchis: `rm -rf /tmp/Orchis-theme` antes del clone (hoy la 2ª corrida falla:
  destino ya existe).
- /etc/environment: idempotente con grep -qxF (hoy `tee -a` DUPLICA las dos
  líneas en cada corrida — el duplicado literal).
- gsettings: con guarda `|| aviso` (DBus puede no estar listo en el contenedor;
  con set -e sin guarda abortaría).
- Refresh por diseño (sin guarda): copias de kitty/.zshrc/p10k/gtk (cp hace
  merge sin duplicar y propagan edits del repo al re-correr).

S6 — Exclusiones y alcance
- Rama sin README ni doc previa de desktop; nada de esas specs aplica.
- apt es naturalmente idempotente; no hay strap/yay que verificar.

S7 — GPU real al contenedor (túnel/passthrough, NO es VM)
Cita usuario: "toma en cuenta que es un invitado docker al cual le aplicamos esa
configuracion asi que dependenias para que funcione correctamente en ese docker
mas no es maquina virtual para instalar drivers graficos, eso si si ejecuta cosas
graficas así que lo que son implementaciones graficas como vulkan o mesa tiene que
estar devido a que por tunel conecto mi grafica real al docker y lo hago, esto
tambien configuralo."
- Sin drivers de huésped VMware (open-vm-tools, xserver-xorg-video-vmware ya
  excluidos): eso es de VM, aquí la GPU viene del host por passthrough.
- Stack GL/Vulkan ya quedó con libgl1-mesa-dri + libglx-mesa0 (S2); se AGREGAN:
  libvulkan1 (loader), vulkan-tools (diagnóstico vulkaninfo) y mesa-va-drivers
  (VA-API AMD; intel-media-va-driver ya estaba para Intel). Verificados en el
  índice binario de kali-rolling.
- Diagnosticar /dev/dri al final de la configuración: si existe → informar,
  agregar el usuario a los grupos video/render (si existen) y probar vulkaninfo;
  si NO existe → aviso con la instrucción (--device /dev/dri en docker run).
- Exclusión documentada: los drivers NVIDIA proprietary NO se instalan dentro
  del contenedor (módulos de kernel = host; vía nvidia-container-toolkit).
- Lo que es del host (fuera del repo): docker run --device /dev/dri y/o
  --gpus all / nvidia-container-toolkit según la tarjeta.

## Tasks

T1  S1,S5  robustez + filtros anti-duplicados en postInstall.sh   inline  commit: pendiente
T2  S2-S4  paquetes verificados + nvim externo + fuente kitty     inline  commit: pendiente
T3  S1-S6  verificación por spec + cierre docs + Engram           inline  commit: pendiente
T4  S7     GPU real vía túnel: vulkan/VA + diagnóstico /dev/dri   inline  commit: pendiente

## Log

L1  "ahora tenemos una rama docker vamos a saltar a ella y vamos a analizarla
    completamante primero y como es un kali igual que en el main vamos a
    corregir lo mismo que en el main kali solo que para docker."
L2  Análisis:27 commits propios (a17bf38 "Configuracion para Docker" →21cde52);
    merge-base con main = f7bd997; árbol = solo files/* + kitty/* + script;
    verificación vivida: índice binario kali-rolling → wmname ausente (quitado),
    resto OK; kitty HackNerdFont roto; zshrcs OK; /etc/environment duplica;
    clones p10k/fzf/orchis sin guarda.
L3  "toma en cuenta que es un invitado docker al cual le aplicamos esa
    configuracion asi que dependenias para que funcione correctamente en ese
    docker mas no es maquina virtual para instalar drivers graficos, eso si si
    ejecuta cosas graficas así que lo que son implementaciones graficas como
    vulkan o mesa tiene que estar devido a que por tunel conecto mi grafica real
    al docker y lo hago, esto tambien configuralo." → nueva spec S7 y task T4.
