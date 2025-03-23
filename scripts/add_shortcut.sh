#!/bin/bash

# Script to add a new custom keyboard shortcut to Gnome
# Usage: ./add-shortcut.sh "<binding>" "command" "name"
# Example: ./add-shortcut.sh "<Super>space" "ulauncher" "ulauncher"
# Partially generated with Claude 3.7

# Check if required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 \"<binding>\" \"command\" \"name\""
  echo "Example: $0 \"<Super>space\" \"ulauncher\" \"ulauncher\""
  exit 1
fi

# Store the arguments
BINDING="$1"
COMMAND="$2"
NAME="$3"

# Define the dconf paths
BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys"

# Create temporary files
TEMP_SHORTCUTS=$(mktemp)
TEMP_UPDATED=$(mktemp)

# Dump the current custom shortcuts configuration to a temp file
dconf dump "$BASE_PATH/" >"$TEMP_SHORTCUTS"

# Count the number of existing custom shortcuts by counting [custom*] occurrences
NUM_SHORTCUTS=$(grep -c "^\[custom[0-9]\+\]" "$TEMP_SHORTCUTS")

# Set the new custom shortcut index
NEW_INDEX=$NUM_SHORTCUTS

echo "Found $NUM_SHORTCUTS existing shortcuts. Adding new shortcut at index $NEW_INDEX."

# Append new shortcut to the temp file
cat >>"$TEMP_SHORTCUTS" <<EOF

[custom$NEW_INDEX]
binding='$BINDING'
command='$COMMAND'
name='$NAME'
EOF

# Get the current list of keyboard shortcut paths
CURRENT_KEYBINDINGS=$(dconf read "${CUSTOM_PATH}/custom-keybindings")

# If there are no custom keybindings yet, initialize with an empty array
if [ -z "$CURRENT_KEYBINDINGS" ] || [ "$CURRENT_KEYBINDINGS" == "@as []" ]; then
  CURRENT_KEYBINDINGS="[]"
fi

# Create the new path for the shortcuts array
NEW_PATH="'$BASE_PATH/custom$NEW_INDEX/'"

# Prepare the new array of shortcuts
if [ "$CURRENT_KEYBINDINGS" == "[]" ]; then
  # If this is the first shortcut
  NEW_KEYBINDINGS="[$NEW_PATH]"
else
  # Add the new shortcut to the existing list
  # Remove the closing bracket, add comma and new path, then close the bracket
  NEW_KEYBINDINGS="${CURRENT_KEYBINDINGS//]/, $NEW_PATH]}"
fi

# Load the updated shortcuts configuration
dconf load "$BASE_PATH/" <"$TEMP_SHORTCUTS"

# Update the custom-keybindings setting
dconf write "$CUSTOM_PATH/custom-keybindings" "$NEW_KEYBINDINGS"

# Clean up temporary files
rm "$TEMP_SHORTCUTS"
rm "$TEMP_UPDATED"

echo "Successfully added new keyboard shortcut:"
echo "Binding: $BINDING"
echo "Command: $COMMAND"
echo "Name: $NAME"
