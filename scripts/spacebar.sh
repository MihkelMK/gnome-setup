#!/bin/bash

POPSHELL_INSTALLED="$1"
DCONF_SPACEBAR=/org/gnome/shell/extensions/space-bar

if $POPSHELL_INSTALLED; then
  # Disable shortcuts that might conflict with Pop Shell
  KEYS_SPACEBAR="$DCONF_SPACEBAR/shortcuts"

  # Open workspace menu: disable <Super>w
  if [ "$(dconf read ${KEYS_SPACEBAR}/open-menu)" != "@as []" ]; then
    echo "Disable workspace menu shortcut <Super>w to limit conflicts with Pop Shell"
    dconf write ${KEYS_SPACEBAR}/open-menu "@as []"
  fi

  # Disable shortcuts that duplicate Pop Shell functionality
  if [ "$(dconf read ${KEYS_SPACEBAR}/move-workspace-left)" != "@as []" ] ||
    [ "$(dconf read ${KEYS_SPACEBAR}/move-workspace-right)" != "@as []" ]; then
    echo "Disable workspace shortcuts - this is handled by Pop Shell"
    dconf write ${KEYS_SPACEBAR}/enable-activate-workspace-shortcuts false
    dconf write ${KEYS_SPACEBAR}/move-workspace-left "@as []"
    dconf write ${KEYS_SPACEBAR}/move-workspace-right "@as []"
  fi
fi

dconf write ${DCONF_SPACEBAR}/behavior/always-show-numbers true
