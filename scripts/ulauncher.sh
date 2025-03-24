#!/bin/bash

POPSHELL_INSTALLED="$1"
KEYS_GNOME_WM=/org/gnome/desktop/wm/keybindings
KEYS_MUTTER=/org/gnome/mutter
KEYS_POPSHELL=/org/gnome/shell/extensions/pop-shell

shortcut_applied() {
  # Check if user confirmed setting custom shortcut
  if test -f "./.confirm_custom_shortcut"; then
    echo "Shortcut already added"
    return 0
  fi

  read -rp "Adding shortcut to open Ulauncher with <Super>space. Are you sure? (Y/n) " CONT
  if test "$CONT" = "n"; then
    echo "Cancelled"
    return 0
  else
    touch "./.confirm_custom_shortcut"
    return 1
  fi
}

# Backup Ulauncher preferences
echo "Backing up Ulauncher config to ~/.config/ulauncher.bak"
cp -r ~/.config/ulauncher ~/.config/ulauncher.bak >/dev/null 2>&1

# Install libadwaita ULauncher theme
if [ ! -d ~/.config/ulauncher/user-themes/libadwaita-dark ]; then
  echo "Installing libadwaita-dark theme for Ulauncher"
  mkdir -p ~/.config/ulauncher/user-themes

  git clone https://github.com/kareemkasem/ulauncher-theme-libadwaita-dark \
    ~/.config/ulauncher/user-themes/libadwaita-dark
fi

cp configs/ulauncher/extensions.json configs/ulauncher/settings.json ~/.config/ulauncher/

# Make Ulauncher start on login
if [ ! -f ~/.config/autostart/ulauncher.desktop ]; then
  echo "Add Ulauncher to ~/.config/autostart"
  cp configs/ulauncher/ulauncher.desktop ~/.config/autostart/
fi

# Disable <Super><Space> and <Super><Shift><Space>
if [ "$(dconf read ${KEYS_GNOME_WM}/switch-input-source)" != "@as []" ] &&
  [ "$(dconf read ${KEYS_GNOME_WM}/switch-input-source-backward)" != "@as []" ]; then
  echo "Disabling conflicting input source switching shortcuts"
  dconf write ${KEYS_GNOME_WM}/switch-input-source "@as []"
  dconf write ${KEYS_GNOME_WM}/switch-input-source-backward "@as []"
fi

# Disable Overview on <Super>
if [ "$(dconf read ${KEYS_MUTTER}/overlay-key)" != "''" ]; then
  echo "Disabling overlay on <Super>"
  dconf write ${KEYS_MUTTER}/overlay-key "''"
fi

# Disable Pop shell launcher
if $POPSHELL_INSTALLED &&
  [ "$(dconf read ${KEYS_POPSHELL}/activate-launcher)" != "@as []" ]; then
  echo "Disabling Pop Shell launcher shortcut"
  dconf write ${KEYS_POPSHELL}/activate-launcher "@as []"
fi

# Add custom shortcut
if ! shortcut_applied; then
  if ! sh scripts/add_shortcut.sh "<Super>space" "ulauncher-toggle" "Open Ulauncher" >/dev/null 2>&1; then
    echo "Failed to add custom shortcut"
  fi
fi
