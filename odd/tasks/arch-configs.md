# Feature: arch-configs — overhaul de script y configs rama arch

Rama `arch` (base 974cc2c). Overhaul de postInstall.sh (paquetes + robustez) y de todo
configs/: picom con blur optimizado para VMware, rofi/rofi-bins funcionales, nvim
externo, limpieza. Sin push (los hace el usuario). Commits al final del análisis.

## Specs

S1 — Neovim externo
Cita usuario: "vamos a eliminar lo referente a neovim tanto en el script como en la carpeta si clonara directamente nvim del repo https://github.com/danystarrkk/nvim"
- Borrar configs/nvim/ del repo completo.
- postInstall.sh: quitar `cp -r $rutaT/nvim ...` (usuario y root); reemplazar por
  `git clone --depth=1 https://github.com/danystarrkk/nvim ~/.config/nvim` (solo usuario;
  sin nvim para root). Guardar si el directorio ya existe.

S2 — Paquetes del script
- `netcat` → `openbsd-netcat` explícito.
- Transacción pacman SOLO con paquetes de repos oficiales.
- Herramientas BlackArch (whatweb ffuf wfuzz burpsuite seclists) en transacción aparte,
  solo si el repo blackarch quedó habilitado tras strap.sh; strap.sh con verificación
  SHA1 (https://blackarch.org/strap.sh.sha1) en directorio temporal. Si falla: aviso y
  continúa sin abortar el resto.
- Lista yay: quitar duplicados (firefox x2, wget/curl/git repetidos vs línea pacman);
  agregar: maim dunst libnotify xdotool alsa-utils viewnior i3lock-fancy mpc
  xorg-xrandr xorg-setxkbmap. Mantener jdk22-graalvm-bin y arc-gtk-theme (existentes en AUR).

S3 — Robustez de postInstall.sh
- `set -Eeuo pipefail`, trap ERR con línea+comando, ctrl_c sale con código 130.
- Prompts: manejar input vacío; test con `[[ "$opt1" == "y" ]]` (comillas).
- `mkdir -p`, `unzip -o`, `git clone` guardado (skip si ya existe el dir).
- /etc/environment idempotente (grep -q antes de append).
- rutas derivadas de la ubicación del script (BASH_SOURCE), no de ~/Entorno.
- Eliminar `cp $rutaT/files/.gitconfig` (el archivo no existe en el repo).
- Agregar `chmod +x` de configs/rofi/bin/* tras copiar rofi.
- systemctl enable de vmware/docker/sddm y gsettings: no fatales (aviso y continúa).
- Eliminar `sudo ln -s -f $rutaP/.zshrc /root/.zshrc` (pisa el .zshrc de root).

S4 — Picom (decisión usuario: glx + blur optimizado; cita: "equilibrio perfecto entre rendimiento en la maquina virtual que sera vmware y la personalizacion cosa como el blur y sombras todo todo optimizalo sin quitarlo")
- backend "glx" (requiere picom ≥10, extra/picom actual), blur-method "dual_kawase",
  blur-size 5, blur-strength 3, blur-background true.
- vsync true, use-damage true, unredir-if-possible true, glx-no-stencil true.
- Sombras más livianas: shadow-radius 9, shadow-opacity 0.5, offsets -7/-7.
- corner-radius 12, round-borders 12 (excluir polybar como hoy).
- Fading conservador: fading true, fade-delta 8, fade-in/out-step 0.08.
- Exclusiones de blur: polybar, desktop, screenshots. Mantener wintypes y shadow-exclude.

S5 — Polybar
- interval de ethernet_status y vpn_status: 2s → 5s; target_status: 2s → 10s.
- enable-ipc = true en [bar/top].
- colors.ini: reemplazar `color0-15 = ${xrdb:color*}` por valores fijos de la paleta.
- launch.sh: quitar `tee -a /tmp/polybar*.log` (logs sin límite); dejar redirección simple.

S6 — Kitty
- `font_family HackNerdFont` → `font_family Hack Nerd Font` (nombre real instalado).
- Mantener opacity 0.98, repaint_delay 10, input_delay 3, sync_to_monitor yes.

S7 — bspwmrc
- Reemplazar `nitrogen --restore &` por `feh --no-fehbg --bg-fill` con el wallpaper
  wallhaven (feh es más liviano en VM; nitrogen se mantiene instalado por decisión previa).
- El resto de bspwmrc se mantiene (xrandr/setxkbmap ahora garantizados por S2).

S8 — Rofi
- config.rasi: `@theme "/home/stark/.local/share/rofi/themes/catppuccin-frappe.rasi"` →
  `@theme "themes/catppuccin-frappe.rasi"` (relativo al dir de config de rofi).
- `icon-theme: "Oranchelo"` → `"Papirus-Dark"`; `terminal: "alacritty"` → `"kitty"`.
- Fuentes Iosevka / Iosevka Nerd Font / feather → `JetBrainsMono Nerd Font` en todos los
  rasi; reemplazar glifos privados de feather por glifos Nerd Font en powermenu.rasi.
- chmod +x configs/rofi/bin/* (runner, powermenu, screenshot, launcher).
- screenshot: iconos dunst_svg inexistentes → nombres del tema Papirus
  (camera-photo, alarm) para dunstify -i.
- powermenu: conservar i3lock-fancy/mpc/amixer (ya cubiertos por S2); quitar dependencia
  de ~/.local/bin/lock si existe fallback con i3lock-fancy.
- userconfig/config.rasi y themes muertos (mpd/network/bluetooth/networkmenu, launcher):
  se dejan intactos (sin tocar, sin borrar).

S9 — Burp Suite (decisión usuario: "Conservar la ruta Pro")
- sxhkdrc super+shift+b sigue apuntando a /opt/Burpsuite-Professional/burpsuitepro.
  Sin cambios.

S10 — zsh root
- files_root/.zshrc: quitar /opt/kitty/bin y /opt/nvim/bin del PATH (inexistentes);
  ruta de syntax-highlighting correcta de Arch
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh.

## Tasks

T1 (S2,S3,S1-script) overhaul completo de postInstall.sh — worker, superficie: postInstall.sh
T2 (S8) arreglos rofi (rasi + bin + permisos) — worker, superficie: configs/rofi/**
T3 (S4) picom.conf glx+blur — inline
T4 (S5) polybar (config.ini, colors.ini, modules.ini, launch.sh) — inline
T5 (S6,S7) kitty.conf + bspwmrc — inline
T6 (S1,S10) borrar configs/nvim/ + files_root/.zshrc — inline
T7 verificación (bash -n, greps, smoke) + commits por unidades de trabajo — inline

## Log

L1 (usuario): "mira estamos dentro de una automatización como podras observar, primero estamos en un commit anteior especifico para arch linux y bueno quiero este commit primero llevarlo a su propia rama para crear una rama propia para arch, luego analizaremos todo el proyecto en esa rama y luego vamos a analizar mejorar y dejar todo correctamente porque tiene errores de paquetes ya no existentes y devemos controlar mejor los errores y mas del script a demas de las configuraciones de entorno que tenemos pero vamos cosa por cosa primero lo de migrar este commit a una rama propia llamada arch."
L2 (usuario): "los commits posterior al analisis de todo y arch es local y remota, pero deja los push por ahora de lado esos los hago yo."
L3 (usuario): "no todo esta bien, ahora en cuanto a algo a agregar antes de comenzar analiza la carpeta de configuraciones toda ella por completo porque si te fijas en el script tenemos 2 partes una de la base y otra de configuraciones vamos a eliminar lo referente a neovim tanto en el script como en la carpeta si clonara directamente nvim del repo https://github.com/danystarrkk/nvim, ahora respecto a configuraciones de bspwm, picom y todo absolutamente todo lo demas vamos a configurarlo en un equilibrio perfecto entre rendimiento en la maquina virtual que sera vmware y la personalizacion cosa como el blur y sombras todo todo optimizalo sin quitarlo solo utiliza la mejor configuracion de cada apartado que veas para que el rendmiento sea el mejor posible y casi no perdamos todo lo visual y bonito que tenemos."
L4 (usuario, decisiones por pregunta): blur = "glx + blur optimizado"; bins faltantes = "Agregar paquetes al script"; burpsuite = "Conservar la ruta Pro".
L5 (evidencia): verificado con pacman -Si y AUR RPC: todo existe salvo lo que requiere BlackArch; arc-gtk-theme OutOfDate pero existe; configs/files/.gitconfig inexistente; rofi/bin en 644; rofi @theme path roto; root .zshrc pisado por ln -s.
L6 (implementación): T3-T6 inline completados y verificados (bash -n / zsh -n / llaves picom / grep xrdb). T1 y T2 delegados a workers en background con superficies disjoint (postInstall.sh | configs/rofi/**).
L7 (T2 done): worker rofi terminó; verificado por parent: modos 755 en bin/{launcher,powermenu,runner,screenshot}, sin Iosevka/feather/Oranchelo/alacritty, guards i3lock-fancy con show_msg. Desviación documentada: userconfig/config.rasi recibió la misma corrección mínima de 3 propiedades (theme relativo/Papirus-Dark/kitty) pese a que S8 decía "sin tocar", porque el criterio de verificación lo exigía; archivo muerto, cambio inocuo, se conserva.
