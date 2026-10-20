# Feature: arch-deps-fixes — dependencias robustas rama arch (JDK21, Arc, idempotencia)

Rama `arch` (base e5227fa). Fix de dependencias del installer tras los errores del
usuario al ejecutarlo: JDK22→JDK21 precompilado, transacción AUR resiliente
(arc-gtk-theme / i3lock-fancy) e idempotencia anti-duplicados para re-runs de prueba.

Slice boundary registrado: el límite ~400 líneas/slice está superado — e5227fa cerró en
1030 líneas / 10 commits sobre origin/main y 59b4bb2 en 1180 / 11 → estrategia:
unidades encadenadas; cada commit es un slice revisable por separado.

## Specs

S1 — JDK21 precompilado
Cita usuario: "vamos a quitar dos cosas de las dependencias 1 es el jdk22 este se
compila y pues demora mucho tiempo lo que yo necesito es el jdk21 ya compilado y
listo para usarse"
- Quitar `jdk22-graalvm-bin` de la línea yay (JDK22 EOL desde sept-2024).
- Agregar `jdk21-openjdk` a la transacción pacman (extra, binario oficial
  21.0.12.1.u1: sin compilación, parches al día).
- Decisión: OpenJDK oficial y no AUR `jdk21-graalvm-bin` (versión 21.0.2 de
  ene-2024, desactualizada en parches) — cumple "compilado y listo" y saca a Java
  del AUR.

S2 — Transacción AUR resiliente (arc-gtk-theme / i3lock-fancy)
Cita usuario: "como segundo el paquete de arc-gtk-theme da error no se encuentra
el paquete así que tambien tenemos que solucionarlo porque da error al intentar la
instalación"
- Diagnóstico vivo: AUR RPC confirma que `arc-gtk-theme` 20221218-2 EXISTE hoy
  (fue borrado y re-creado el 31-03-2025; huérfano el 10-03-2025 → frágil).
  `i3lock-fancy` NO existe ni en AUR ni en repos oficiales de Arch (sí existe en
  Kali): yay aborta la transacción COMPLETA ante un target inexistente, igual que
  pacman con BlackArch — esa es la causa raíz del error al instalar.
- Mover los AUR (arc-gtk-theme, nitrogen, i3lock-fancy-git) a su propio bucle con
  guarda: si uno falla → aviso amarillo y continúa el resto.
- Reemplazar `i3lock-fancy` → `i3lock-fancy-git` (AUR, mantenida por el autor
  meskarune, `provides=('i3lock-fancy')`, binario `i3lock-fancy` que invoca
  powermenu; depende de `i3lock` de repo + imagemagick).
- La línea yay principal queda SOLO con paquetes de repos oficiales (los 46
  verificados contra archlinux.org).

S3 — Idempotencia anti-duplicados (re-runs para pruebas)
Cita usuario: "ahora verificaciones para evitar duplicados tambien por ejemplo en
las instalaciones de blackarch y yay espero que si tenga primero una verificacion
de si ya esta y luego dependiendo de si o no prosiga y lo mismo para lo demas, esto
es importante para poder hacer pruebas o en especial sobre ejecutar el script y
evitar duplicados."
- BlackArch: si `[blackarch]` ya está en /etc/pacman.conf → se omite TODO el
  bloque strap.sh (descarga + SHA1 + ejecución + segundo pacman -Syu); solo corre
  si el repo no está habilitado. La instalación de tools BlackArch ya tenía esa
  verificación.
- yay: si `command -v yay` → se omite clone + makepkg por completo; si existe el
  directorio pero no yay → se omite solo el clone.
- Fuentes: omitir wget/unzip si `configs/fonts/HackNerdFonts` (o JetBrainsMono)
  no está vacío; copia a /usr/share/fonts + fc-cache solo si
  `/usr/share/fonts/HackNerdFonts` no existe.
- Plugin sudo de zsh: omitir wget si `/usr/share/zsh-sudo/sudo.plugin.zsh` existe.
- Sin cambios (ya idempotentes): transacciones pacman/yay con --needed, clones
  git guardados (nvim, p10k x2, fzf x2), /etc/environment con grep -q, tee de
  settings gtk sobrescribe, rm+cp de polybar es diseño.

S4 — Filtros de configuracionEntorno (re-runs)
Cita usuario: "ahora en cuanto a la configuracion del entorno tambien aplica
ciertos filtros para que no se dupliquen y genere errores."
- Quitar la copia DUPLICADA de kitty para root (se copiaba dos veces en la
  misma corrida: junto al kitty de usuario y otra en el bloque root-zshrc).
- Guardar la copia de wallpapers: omitir si $rutaP/Pictures/wallpapers ya
  existe (evita re-copiar MB en cada corrida).
- Quitar `sudo touch /root/.zshrc`: código muerto (el bloque siguiente lo
  elimina con rm -rf justo antes del cp definitivo).
- Las copias de configs (bspwm, sxhkd, picom, kitty, polybar, rofi) SE
  REFRESCAN a propósito en cada corrida: cp -r con destino existente hace
  merge (no duplica) y es lo que permite probar edits del repo re-ejecutando
  el script. Igual los rm+cp de .zshrc/polybar: refresh por diseño.
- Confirmado sin cambio: fzf install corre tras el cp del .zshrc (bloque
  agregado una sola vez por corrida), chsh idempotente, systemctl con guarda,
  gsettings con guarda, tee de gtk sobrescribe, mkdir -p en todos lados.

## Tasks

T9  S1   jdk22-graalvm-bin → jdk21-openjdk en transacción pacman   inline  commit: 59b4bb2
T10 S2   split AUR guardado + reemplazo i3lock-fancy-git            inline  commit: 59b4bb2
T11 S3   idempotencia strap/yay/fuentes/plugin zsh-sudo             inline  commit: 59b4bb2
T12 S4   filtros de configuracionEntorno (kitty dup, wallpapers, touch) inline commit: pendiente

## Log

L1  "vamos a quitar dos cosas de las dependencias 1 es el jdk22 este se compila y
    pues demora mucho tiempo lo que yo necesito es el jdk21 ya compilado y listo
    para usarse, eso como primero y como segundo el paquete de arc-gtk-theme da
    error no se encuentra el paquete así que tambien tenemos que solucionarlo
    porque da error al intentar la instalación, ahora verificaciones para evitar
    duplicados tambien por ejemplo en las instalaciones de blackarch y yay espero
    que si tenga primero una verificacion de si ya esta y luego dependiendo de si
    o no prosiga y lo mismo para lo demas, esto es importante para poder hacer
    pruebas o en especial sobre ejecutar el script y evitar duplicados."
L2  Evidencia de investigación: AUR RPC v5 live — arc-gtk-theme 20221218-2 ✓,
    nitrogen 1.6.1-6 ✓, jdk22-graalvm-bin 22.0.2-3 ✓ (EOL), jdk21-graalvm-bin
    21.0.2-2 ✓ (viejo), i3lock-fancy 0 resultados ✗. archlinux.org API: los otros
    46 paquetes de la línea yay están en repos oficiales. PKGBUILD de
    i3lock-fancy-git: provides=('i3lock-fancy'), make install del script del autor.
    jdk21-openjdk: extra 21.0.12.1.u1 (binario,535 archivos).
L3  Verificación post-cambio (59b4bb2): bash -n OK; jdk21-openjdk presente y
    jdk22 solo en comentario; bucle AUR con los 3 paquetes y 0 i3lock-fancy
    suelto en la línea yay principal (empieza 'dconf glib2 papirus-icon-theme');
    las 6 guardas anti-duplicados presentes (strap, yay, 2 de fuentes,
    /usr/share/fonts, plugin zsh-sudo); makepkg aparece solo1 vez y dentro de
    la guarda de yay.
L4  "ahora en cuanto a la configuracion del entorno tambien aplica ciertos
    filtros para que no se dupliquen y genere errores." → nueva spec S4 y task T12.
