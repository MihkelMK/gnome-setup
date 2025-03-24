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

setup_popshell() {
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

# Install Pop shell
INDEX=1
TITLE="Pop Shell Extension"
DESC="Tiling windows managed with keyboard"
POPSHELL_INSTALLED=$(gnome-extensions list | grep -q "pop-shell")

if confirm_install "$INDEX" "$TITLE" "$DESC"; then
  # False only if it wasn't installed before and user cancels install
  if setup_popshell "$POPSHELL_INSTALLED"; then
    export POPSHELL_INSTALLED=true
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
  fi
fi

# Install Space Bar
INDEX=3
TITLE="Space Bar Extension"
DESC="Show workspaces as numbers in top panel"

if confirm_install "$INDEX" "$TITLE" "$DESC"; then
  if bash scripts/pacman_install.sh "Space Bar Extension" "gnome-shell-extension-space-bar-git"; then
    bash scripts/spacebar.sh "$POPSHELL_INSTALLED"
  fi
fi
