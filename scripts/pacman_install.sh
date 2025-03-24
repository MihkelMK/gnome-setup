#!/bin/bash

# Script to install a pacman package
# Usage: ./pacman_install.sh "name" "package" (optional "yes" to not prompt user)
# Example: ./pacman_install.sh "Zen Browser" "zen-browser"
# Partially generated with Claude 3.7

# Check if required arguments are provided
if [ $# -lt 2 ] || [ $# -gt 4 ]; then
  echo "Usage: $0 \"name\" \"package\" (optional \"yes\" to not prompt user)"
  echo "Example: $0 \"Zen Browser\" \"zen-browser\""
  exit 1
fi

# Store the arguments
NAME="$1"
PACKAGE="$2"
NO_PROMPTS=false

if [ "$3" == "yes" ]; then
  export NO_PROMPTS=true
fi

# Check if already installed
if pacman -Q "$PACKAGE" &>/dev/null; then
  echo "$NAME is already installed"
  exit 0
fi

# Not installed, prompt user to install
echo "$NAME is not installed."

if ! $NO_PROMPTS; then
  read -pr "Would you like to install $NAME with pacman? (y/n): " answer
fi

if [[ "$NO_PROMPTS" || "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Installing $PACKAGE..."
  # Using sudo to ensure admin privileges

  if sudo pacman -S "$PACKAGE"; then
    echo "$NAME successfully installed from $PACKAGE."
  else
    echo "Installation failed. You may need to enable the AUR or use an AUR helper like yay."
    echo "Try: yay -S $PACKAGE"
    exit 1
  fi
else
  echo "Installation cancelled."
  exit 1
fi
