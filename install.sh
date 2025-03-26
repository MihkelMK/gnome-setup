#!/bin/bash

confirm_install() {
  INDEX="$1"
  TITLE="$2"
  DESC="$3"

  # Add separator newline between prompts
  if [ "$INDEX" -gt 1 ]; then
    echo
  fi

  echo "$INDEX. $TITLE - $DESC"

  read -rp "Install and configure? (Y/n) " CONT
  if test "$CONT" = "n"; then
    return 1
  fi

  return 0
}

install_popshell() {
  POPSHELL_INSTALLED="$1"

  if ! $POPSHELL_INSTALLED; then
    # Extension not installed
    if ! bash scripts/pacman_install.sh "Pop Shell Extension" "gnome-shell-extension-pop-shell-git"; then
      # User cancelled install/install failed
      echo "Pop Shell extension not installed. Skipping setup."
      return 1
    fi
  fi

  # Load Pop shell config
  bash scripts/tiling.sh

  return 0
}

install_themes() {
  # Theme GTK3 apps
  if ! bash scripts/pacman_install.sh "GTK3 port of Libadwaita" "adw-gtk-theme" "yes"; then
    return 1
  fi

  # Theme QT5 apps
  if ! bash scripts/pacman_install.sh "Qt5 Configuration Utility" "qt5ct" "yes"; then
    return 1
  fi
  if ! bash scripts/pacman_install.sh "SVG-based theme engine for Qt5" "kvantum-qt5" "yes"; then
    return 1
  fi
  if ! bash scripts/pacman_install.sh "Adwaita-like client-side decorations for Qt5" "qadwaitadecorations-qt5" "yes"; then
    return 1
  fi

  # Theme QT6 apps
  if ! bash scripts/pacman_install.sh "Qt6 Configuration Utility" "qt6ct" "yes"; then
    return 1
  fi
  if ! bash scripts/pacman_install.sh "SVG-based theme engine for Qt6" "kvantum" "yes"; then
    return 1
  fi
  if ! bash scripts/pacman_install.sh "Adwaita-like client-side decorations for Qt6" "qadwaitadecorations-qt6" "yes"; then
    return 1
  fi

  # Install libadwaita theme for kvantum
  if ! bash scripts/pacman_install.sh "Libadwaita theme for Kvantum" "kvantum-theme-libadwaita-git" "yes"; then
    return 1
  fi

  return 0
}

# Install Pop shell
INDEX=1
TITLE="Pop Shell Extension"
DESC="Tiling windows managed with keyboard"
POPSHELL_INSTALLED=$(gnome-extensions list | grep -q "pop-shell")

if confirm_install "$INDEX" "$TITLE" "$DESC"; then
  # False only if it wasn't installed before and user cancels install
  if install_popshell "$POPSHELL_INSTALLED"; then
    export POPSHELL_INSTALLED=true
    echo "$TITLE setup finished"
  fi
fi

# Install Ulauncher
INDEX=2
TITLE="Ulauncher"
DESC="My preffered app launcher"

if $POPSHELL_INSTALLED; then
  DESC="$DESC (replaces Pop Launcher)"
fi

if confirm_install "$INDEX" "$TITLE" "$DESC"; then
  if bash scripts/pacman_install.sh "Ulauncher" "ulauncher"; then
    bash scripts/ulauncher.sh "$POPSHELL_INSTALLED"
    echo "$TITLE setup finished"
  fi
fi

# Install Space Bar
INDEX=3
TITLE="Space Bar Extension"
DESC="Show workspaces as numbers in top panel"

if confirm_install "$INDEX" "$TITLE" "$DESC"; then
  if bash scripts/pacman_install.sh "Space Bar Extension" "gnome-shell-extension-space-bar-git"; then
    bash scripts/spacebar.sh "$POPSHELL_INSTALLED"
    echo "$TITLE setup finished"
  fi
fi

# Fonts
INDEX=4
TITLE="Fira Sans"
DESC="Use Fira Sans for interface text"
CUSTOM_FONT=false
INTERFACE_DCONF=/org/gnome/desktop/interface

if confirm_install "$INDEX" "$TITLE" "$DESC"; then
  if bash scripts/pacman_install.sh "Fira Sans" "ttf-fira-sans"; then

    dconf write ${INTERFACE_DCONF}/font-name "'Fira Sans 11'"
    dconf write ${INTERFACE_DCONF}/document-font-name "'Fira Sans 11'"

    export CUSTOM_FONT=true
    echo "$TITLE setup finished"
  fi
elif [ "$(dconf read ${INTERFACE_DCONF}/font-name)" == "'Fira Sans 11'" ]; then
  export CUSTOM_FONT=true
  echo "$TITLE already used for interface text"
fi

# Themes
INDEX=5
TITLE="Themes"
DESC="Make GTK3, Qt5 and Qt6 look like Libadwaita"

if confirm_install "$INDEX" "$TITLE" "$DESC"; then
  echo "This will install packages: adw-gtk-theme, qt5ct, qt6ct, kvantum-qt5, kvantum, qadwaitadecorations-qt5, qadwaitadecorations-qt6 and kvantum-theme-libadwaita-git."

  read -rp "Are you sure? (Y/n) " CONT
  if ! test "$CONT" = "n"; then
    echo "Installing required packages"

    if install_themes; then
      echo
      bash scripts/themes.sh "$CUSTOM_FONT"
      echo "$TITLE setup finished"
    else
      echo "Packages failed to install. Setup cancelled."
    fi
  fi

fi
