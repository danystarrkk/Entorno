#!/bin/bash
# arch-autoinstall.sh - Instalación mínima de Arch Linux

set -e # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
log() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

info() {
  echo -e "${BLUE}[+]${NC} $1"
}

# =============================================================================
# PASO 1: VERIFICACIÓN INICIAL BÁSICA
# =============================================================================
info "Iniciando verificación inicial..."

# Verificar que se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
  error "Este script debe ejecutarse como root. Usa: sudo su"
fi

# Verificar que estamos en Arch Linux (live environment)
if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
  error "Este script debe ejecutarse desde el Live ISO de Arch Linux"
fi

log "Entorno Live ISO verificado correctamente."

# =============================================================================
# PASO 2: VERIFICACIÓN DE CONEXIÓN A INTERNET
# =============================================================================
info "Verificando conexión a internet..."

if ping -c 1 -W 3 archlinux.org >/dev/null 2>&1; then
  log "Conexión a internet detectada."
else
  error "No hay conexión a internet. Configura internet y vuelve a ejecutar el script."
fi

# =============================================================================
# PASO 3: DETECCIÓN AUTOMÁTICA DE DISCO
# =============================================================================
info "Detectando disco principal..."

# Para VMware: generalmente /dev/sda
DISK=$(lsblk -dn -o NAME | grep -E '^sd[a-z]$' | head -n 1)

if [ -z "$DISK" ]; then
  # Intentar otro patrón común en VMs
  DISK=$(lsblk -dn -o NAME | grep -E '^vd[a-z]$' | head -n 1)
fi

if [ -z "$DISK" ]; then
  error "No se pudo detectar el disco principal automáticamente."
fi

MAIN_DISK="/dev/$DISK"
log "Disco principal detectado: $MAIN_DISK"

# Verificar que el disco existe
if [ ! -b "$MAIN_DISK" ]; then
  error "El disco $MAIN_DISK no existe o no es un block device."
fi

# =============================================================================
# PASO 4: CONFIGURACIÓN INTERACTIVA
# =============================================================================
info "Configuración del sistema"

# Pedir solo la información esencial
read -p "Nombre de usuario: " USERNAME
while [ -z "$USERNAME" ]; do
  read -p "El nombre de usuario no puede estar vacío: " USERNAME
done

read -sp "Contraseña para root: " ROOT_PASSWORD
echo
while [ -z "$ROOT_PASSWORD" ]; do
  read -sp "La contraseña root no puede estar vacía: " ROOT_PASSWORD
  echo
done

read -sp "Contraseña para $USERNAME: " USER_PASSWORD
echo
while [ -z "$USER_PASSWORD" ]; do
  read -sp "La contraseña de usuario no puede estar vacía: " USER_PASSWORD
  echo
done

# =============================================================================
# PASO 5: PARTICIONADO AUTOMÁTICO (BIOS/MBR) - TODO EL DISCO
# =============================================================================
info "Iniciando particionado automático (usando TODO el disco)..."

# Limpiar tabla de particiones existente
log "Limpiando tabla de particiones..."
wipefs -a "$MAIN_DISK"

# Crear tabla de particiones MBR (para BIOS)
log "Creando tabla de particiones MBR..."
printf "o\nw\n" | fdisk "$MAIN_DISK"

# Crear partición raíz (toda el disco)
log "Creando partición raíz (100% del disco)..."
printf "n\np\n1\n\n\nw\n" | fdisk "$MAIN_DISK"

# Formatear partición como ext4
ROOT_PARTITION="${MAIN_DISK}1" # ← ¡CORREGIDO! Estaba mal escrito
log "Formateando $ROOT_PARTITION como ext4..."
mkfs.ext4 -F "$ROOT_PARTITION"

# Montar partición
log "Montando partición raíz..."
mount "$ROOT_PARTITION" /mnt # ← ¡CORREGIDO! Estaba mal escrito

log "Particionado completado exitosamente."

# =============================================================================
# PASO 6: INSTALACIÓN DEL SISTEMA BASE
# =============================================================================
info "Instalando sistema base con kernel LTS..."

# Instalar paquetes mínimos esenciales con kernel LTS
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware \
  sudo nano git curl dhcpcd grub bash-completion

# Generar fstab
log "Generando fstab..."
genfstab -U /mnt >>/mnt/etc/fstab

# =============================================================================
# PASO 7: CONFIGURACIÓN DEL SISTEMA BASE
# =============================================================================
info "Configurando sistema base..."

# Chroot al sistema instalado
arch-chroot /mnt /bin/bash <<EOF
# Configurar zona horaria de Ecuador/Guayaquil
ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime
hwclock --systohc

# Configurar locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Configurar teclado US Alt International
echo "KEYMAP=us" > /etc/vconsole.conf
echo "XKBLAYOUT=us" >> /etc/vconsole.conf
echo "XKBVARIANT=alt-intl" >> /etc/vconsole.conf

# Configurar hostname como "beater"
echo "beater" > /etc/hostname

# Configurar hosts
cat << HOSTS >> /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   beater.localdomain beater
HOSTS

# Configurar contraseña de root
echo "root:$ROOT_PASSWORD" | chpasswd

# Crear usuario principal
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd

# Configurar sudo para el usuario
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Crear directorios de usuario estándar
sudo -u $USERNAME mkdir -p /home/$USERNAME/{Desktop,Documents,Downloads,Music,Pictures,Public,Templates,Videos}
EOF

# =============================================================================
# PASO 8: INSTALACIÓN DE BLACKARCH REPOSITORY
# =============================================================================
info "Instalando repositorio BlackArch..."

arch-chroot /mnt /bin/bash <<EOF
# Descargar e instalar BlackArch
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
./strap.sh

# Limpiar instalación
rm strap.sh

# Prioridades para evitar conflictos
cat << PACMAN >> /etc/pacman.conf
[options]
CacheDir = /var/cache/pacman/pkg/
CleanMethod = KeepCurrent
PACMAN
EOF

# =============================================================================
# PASO 9: INSTALACIÓN DE OPEN-VM-TOOLS
# =============================================================================
info "Instalando y configurando open-vm-tools..."

arch-chroot /mnt /bin/bash <<EOF
# Instalar open-vm-tools para VMware
pacman -S --noconfirm --needed open-vm-tools

# Habilitar servicios de VMware
systemctl enable vmtoolsd.service
systemctl enable vmware-vmblock-fuse.service
EOF

# =============================================================================
# PASO 10: INSTALACIÓN Y CONFIGURACIÓN DE GRUB (BIOS)
# =============================================================================
info "Instalando GRUB bootloader..."

arch-chroot /mnt /bin/bash <<EOF
# Instalar GRUB para BIOS
grub-install --target=i386-pc "$MAIN_DISK"

# Generar configuración de GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF

# =============================================================================
# PASO 11: HABILITAR SERVICIOS ESENCIALES
# =============================================================================
info "Configurando servicios esenciales..."

arch-chroot /mnt /bin/bash <<EOF
# Habilitar servicios de red
systemctl enable dhcpcd.service
systemctl enable systemd-resolved.service

# Optimizar para VM
echo "vm.swappiness=10" >> /etc/sysctl.d/99-vm.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.d/99-vm.conf
EOF

# =============================================================================
# PASO 12: LIMPIEZA Y FINALIZACIÓN
# =============================================================================
info "Finalizando instalación..."

# Limpiar cache de paquetes
arch-chroot /mnt /bin/bash <<EOF
rm -rf /var/cache/pacman/pkg/*
EOF

# Desmontar particiones
umount -R /mnt

log "¡Instalación completada exitosamente!"
log "╔════════════════════════════════════════════════╗"
log "║                 BEATER READY                   ║"
log "║                                                ║"
log "║  Sistema: Arch Linux Minimalista               ║"
log "║  Hostname: beater                              ║"
log "║  Kernel: LTS (Estable)                         ║"
log "║  Usuario: $USERNAME                            ║"
log "║  Zona Horaria: America/Guayaquil (Ecuador)     ║"
log "║  Teclado: US Alt International                 ║"
log "║  VMware Tools: Instalado y configurado         ║"
log "╚════════════════════════════════════════════════╝"
log ""
log "✅ Particionado: TODO el disco ($MAIN_DISK) utilizado"
log "✅ Sistema de archivos: ext4"
log "✅ Directorios de usuario creados:"
log "   • Desktop, Documents, Downloads, Music"
log "   • Pictures, Public, Templates, Videos"
log ""
log "✅ Servicios de VMware habilitados:"
log "   • vmtoolsd.service"
log "   • vmware-vmblock-fuse.service"
log ""
log "Para reiniciar:"
log "1. exit"
log "2. umount -a"
log "3. reboot"
log ""
log "Después del reinicio, ejecuta el script de post-instalación"
log "para instalar YAY y las herramientas adicionales"

# Guardar información de la instalación
cat <<INFO >/tmp/installation-info.txt
BEATER - ARCH LINUX MINIMAL INSTALLATION
========================================
Fecha: $(date)
Usuario: $USERNAME
Hostname: beater
Disco: $MAIN_DISK
Partición: ${MAIN_DISK}1 (100% del disco)
Sistema archivos: ext4
Kernel: LTS
Zona Horaria: America/Guayaquil (Ecuador)
Teclado: US Alt International
VMware Tools: Instalado y configurado
Servicios habilitados: vmtoolsd, vmware-vmblock-fuse
NOTA: YAY se instalará en el post-install
INFO

log "Información de instalación guardada en /tmp/installation-info.txt"
