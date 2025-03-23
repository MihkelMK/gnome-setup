#!/bin/bash

# Script to install a pacman package
# Usage: ./pacman_install.sh "name" "package"
# Example: ./pacman_install.sh "Zen Browser" "zen-browser"
# Partially generated with Claude 3.7

# Check if required arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 \"name\" \"package\""
  echo "Example: $0 \"Zen Browser\" \"zen-browser\""
  exit 1
fi

# Store the arguments
NAME="$1"
PACKAGE="$2"

# Check if already installed
if pacman -Q "$PACKAGE" &>/dev/null; then
  echo "$NAME is already installed"
  exit 0
fi

# Not installed, prompt user to install
echo "$NAME is not installed."
read -pr "Would you like to install $NAME with pacman? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo "Installing $PACKAGE..."
  # Using sudo to ensure admin privileges

  if sudo pacman -S "$PACKAGE"; then
    echo "$NAME successfully installed from $PACKAGE."
  else
    echo "Installation failed. You may need to enable the AUR or use an AUR helper like yay."
    echo "Try: yay -S $NAME"
    exit 1
  fi
else
  echo "Installation cancelled."
  exit 1
fi
