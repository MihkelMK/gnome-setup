#!/bin/bash

KEYS_GNOME_WM=/org/gnome/desktop/wm/keybindings
KEYS_MUTTER=/org/gnome/mutter

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
echo "Installing libadwaita-dark theme for Ulauncher"
mkdir -p ~/.config/ulauncher/user-themes

if [ ! -d ~/.config/ulauncher/user-themes/libadwaita-dark ]; then
  git clone https://github.com/kareemkasem/ulauncher-theme-libadwaita-dark \
    ~/.config/ulauncher/user-themes/libadwaita-dark
fi

cp configs/ulauncher/extensions.json configs/ulauncher/settings.json ~/.config/ulauncher/

# Disable <Super><Space> and <Super><Shift><Space>
echo "Disabling conflicting input source switching shortcuts"
dconf write ${KEYS_GNOME_WM}/switch-input-source "@as []"
dconf write ${KEYS_GNOME_WM}/switch-input-source-backward "@as []"

# Disable Overview on <Super>
echo "Disabling overlay on <Super>"
dconf write ${KEYS_MUTTER}/overlay-key "''"

# Check if the Pop shell installed
echo "Disabling Pop Shell launcher shortcut"
if dconf read /org/gnome/shell/extensions/pop-shell/activate-launcher &>/dev/null; then
  # Disable Pop shell launcher
  dconf write /org/gnome/shell/extensions/pop-shell/activate-launcher "@as []"
fi

# Add custom shortcut
if ! shortcut_applied; then
  if ! sh scripts/add_shortcut.sh "<Super>space" "ulauncher-toggle" "Open Ulauncher" >/dev/null 2>&1; then
    echo "Failed to add custom shortcut"
  fi
fi

# Make Ulauncher start on login
echo "Add Ulauncher to ~/.config/autostart"
cp configs/ulauncher/ulauncher.desktop ~/.config/autostart/
