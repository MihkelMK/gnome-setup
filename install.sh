#! /bin/bash

SKIP_POPSHELL=false
POPSHELL_INSTALLED=false

if gnome-extensions list | grep -q "pop-shell"; then
  export POPSHELL_INSTALLED=true
else
  if sh scripts/pacman_install.sh "Pop Shell Extension" "gnome-shell-extension-pop-shell-git"; then
    export POPSHELL_INSTALLED=true
  else
    export SKIP_POPSHELL=true
    echo "Pop Shell extension not installed. Skipping setup."
  fi
  echo
fi

if ! $SKIP_POPSHELL; then
  read -rp "Install Pop Shell setup? (Y/n) " CONT
  if ! test "$CONT" = "n"; then
    # Load PopOS shell extensions config
    sh scripts/tiling.sh
  fi
fi

SKIP_ULAUNCHER=false

if $POPSHELL_INSTALLED; then
  echo
  read -rp "Replace Pop Launcher with Ulauncher? (Y/n) " CONT
  if test "$CONT" = "n"; then
    export SKIP_ULAUNCHER=true
  fi
else
  echo
  read -rp "Install Ulauncher? (Y/n) " CONT
  if test "$CONT" = "n"; then
    export SKIP_ULAUNCHER=true
  fi
fi

if ! $SKIP_ULAUNCHER; then
  if sh scripts/pacman_install.sh "Ulauncher" "ulauncher"; then
    # Setup Ulauncher
    sh scripts/ulauncher.sh
  fi
fi
