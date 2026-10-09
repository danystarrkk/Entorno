# 🖥️ Entorno de escritorio Linux personalizado (HackStark)

Herramienta basada en Bash para instalar dependencias y configurar un entorno de escritorio Linux orientado a la productividad, el desarrollo y el trabajo técnico.

El script prepara un entorno basado en **BSPWM y SXHKD**, incorpora herramientas de terminal y desarrollo, configura una estética oscura y aplica ajustes tanto al usuario actual como al usuario `root`.

El objetivo es simplificar la preparación de un entorno de trabajo consistente, reuniendo la instalación de paquetes, la configuración de aplicaciones y la personalización visual en un mismo procedimiento.

## ✨ Características

- 🪟 **Gestión de ventanas:** configuración de BSPWM y SXHKD para controlar el escritorio mediante atajos de teclado.
- 🎨 **Personalización visual:** tema oscuro Arc-Dark, iconos Papirus-Dark y fondos de pantalla.
- 💻 **Terminal personalizada:** Kitty, Zsh y Powerlevel10k para una experiencia de terminal configurable.
- 🔤 **Tipografías:** instalación de Hack Nerd Font y JetBrains Mono, además de otras fuentes para mejorar la compatibilidad visual.
- 🛠️ **Herramientas de desarrollo:** Neovim, Git, npm, ripgrep, bat, lsd y fzf.
- 🖌️ **Composición del escritorio:** integración de Picom, Polybar, Rofi y herramientas para gestionar fondos y pantallas.
- 🐳 **Contenedores:** instalación y habilitación de Docker.
- 🖥️ **Integración con máquinas virtuales:** instalación de Open VM Tools para entornos compatibles con VMware.
- ⚙️ **Configuración de usuario y root:** preparación de archivos de configuración para ambos contextos.

## 🧰 Componentes principales

| Componente    | Función                             |
| ------------- | ----------------------------------- |
| BSPWM         | Gestor de ventanas en mosaico       |
| SXHKD         | Gestor de atajos de teclado         |
| Picom         | Compositor gráfico                  |
| Polybar       | Barra de estado                     |
| Rofi          | Lanzador de aplicaciones y selector |
| Kitty         | Emulador de terminal                |
| Zsh           | Shell interactiva                   |
| Powerlevel10k | Tema y personalización del prompt   |
| Neovim        | Editor de texto                     |
| fzf           | Búsqueda interactiva en la terminal |
| Docker        | Ejecución y gestión de contenedores |

## 📋 Requisitos

Antes de ejecutar el script, asegúrate de contar con:

- Una distribución Linux basada en Debian o Ubuntu.
- Una sesión gráfica compatible con las herramientas que se van a configurar.
- Acceso a `sudo` para instalar paquetes y modificar archivos del sistema.
- Conexión a Internet para descargar dependencias, fuentes y repositorios.
- Git, `wget` y `unzip` disponibles durante la configuración.
- Los archivos de configuración requeridos por el script.

### Estructura esperada

El script utiliza el directorio `~/Entorno/configs` como fuente de los archivos de configuración. Por tanto, debes disponer de una estructura equivalente a la siguiente:

```text
~/Entorno/
└── configs/
    ├── bspwm/
    ├── sxhkd/
    ├── fonts/
    ├── wallpapers/
    ├── nvim/
    ├── kitty/
    ├── picom/
    ├── polybar/
    ├── rofi/
    ├── files/
    │   ├── .zshrc
    │   ├── .p10k.zsh
    │   └── .gitconfig
    └── files_root/
        ├── .zshrc
        └── .p10k.zsh
```

Esta estructura representa las rutas que el script espera utilizar; los directorios y archivos deben existir previamente o prepararse según corresponda.

## 🚀 Uso

### 1. Obtener los archivos

Coloca el script y el directorio de configuraciones en las rutas esperadas.

### 2. Dar permisos de ejecución

```bash
chmod +x install.sh
```

### 3. Ejecutar la herramienta

```bash
./install.sh
```

El script solicitará la contraseña de `sudo` al comienzo y mantendrá la autorización activa durante la ejecución.

### 4. Instalar las dependencias

Se mostrará una pregunta para confirmar la instalación de los paquetes necesarios. Introduce `y` para continuar con la actualización de paquetes y la instalación de dependencias.

Si decides omitir este paso, algunas funciones podrían no estar disponibles.

### 5. Configurar el entorno

A continuación, podrás confirmar la aplicación de las configuraciones del escritorio, terminal, fuentes, temas y herramientas.

Una vez finalizado el proceso, cierra la sesión o reinicia el entorno gráfico cuando sea necesario para aplicar los cambios.

## 🎨 Personalización visual

La configuración establece una apariencia oscura mediante:

- Arc-Dark como tema GTK.
- Papirus-Dark como conjunto de iconos.
- Hack Nerd Font y JetBrains Mono como tipografías complementarias.
- Ajustes de preferencia visual para aplicaciones GTK y Qt.
- Configuración de Kitty, Polybar, Rofi y Picom.
- Fondos de pantalla y scripts asociados al entorno BSPWM.

La apariencia final depende de la sesión gráfica, las versiones instaladas y la compatibilidad de cada aplicación.

## 🔧 Qué realiza durante la configuración

El procedimiento se divide en dos etapas principales:

**1. Instalación de dependencias**

Actualiza los índices de paquetes, actualiza el sistema e instala las herramientas y bibliotecas declaradas en el script.

**2. Aplicación de configuraciones**

Descarga tipografías y repositorios externos, copia archivos de configuración, prepara directorios de usuario y de `root`, cambia la shell predeterminada y habilita determinados servicios del sistema.

El script también instala fzf y configura preferencias de apariencia oscura para distintos componentes del escritorio.

## ⚠️ Consideraciones importantes

- **Revisa los archivos de configuración antes de ejecutar el script.** Algunas configuraciones existentes del usuario serán eliminadas y reemplazadas.
- **Se realizan modificaciones con privilegios administrativos.** El procedimiento escribe archivos en `/etc`, instala paquetes y modifica configuraciones de `root`.
- **La shell predeterminada cambia a Zsh.** Comprueba que esté instalada y que la ruta `/bin/zsh` sea válida en tu distribución.
- **Se habilitan servicios del sistema.** Docker y Open VM Tools se configuran para iniciarse automáticamente cuando corresponda.
- **Las configuraciones dependen del entorno gráfico.** Los ajustes de GNOME y GTK pueden no aplicarse íntegramente en otras sesiones.
- **No todas las distribuciones son compatibles.** Los paquetes declarados están orientados principalmente a sistemas basados en Debian y Ubuntu.
- **Las descargas externas requieren conexión a Internet.** Los cambios en repositorios, versiones o URL pueden afectar la instalación.
- **La ejecución no es completamente reversible.** Realiza una copia de seguridad de tus configuraciones y revisa los cambios antes de continuar.

## 🎯 Objetivo

Proporcionar una base reproducible para preparar un entorno Linux personalizado que reúna herramientas de productividad, desarrollo y administración en una interfaz de escritorio ligera y configurable.

La herramienta reduce el trabajo manual de instalación y configuración, pero requiere revisar previamente los archivos de configuración y adaptar las dependencias a la distribución utilizada.
