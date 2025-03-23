#!/bin/bash

# Based on code from the pop-os/shell repo, specifically this file:
# https://github.com/pop-os/shell/blob/94f0953a4f854ec2c21033916e5268e1891a261c/scripts/configure.sh

shortcut_applied() {
    # Check if user confirmed overriding shortcuts
    if test -f "./.confirm_shortcut_change"; then
        echo "Shortcut change already confirmed"
        return 0
    fi

    read -rp "Overriding your default shortcuts. Are you sure? (Y/n) " CONT
    if test "$CONT" = "n"; then
        echo "Cancelled"
        return 0
    else
        touch "./.confirm_shortcut_change"
        return 1
    fi
}

defaults_changed() {
    # Check if user confirmed settings my defaults
    if test -f "./.confirm_custom_defaults"; then
        echo "Defaults already changed"
        return 0
    fi

    read -rp "Overwriding default Pop shell settings. Are you sure? (Y/n) " CONT
    if test "$CONT" = "n"; then
        echo "Cancelled"
        return 0
    else
        touch "./.confirm_custom_defaults"
        return 1
    fi
}

set_keybindings() {
    if shortcut_applied; then
        return 0
    fi

    left="a"
    down="s"
    up="w"
    right="d"

    tile_mod="<Alt>"
    workspace_mod="<Super>"
    layer_two="<Shift>"
    layer_three="<Primary>"

    stack_key="e"
    float_key="f"
    rotate_key="r"

    # Outside management mode
    workspace_switch="${workspace_mod}"
    workspace_move="${workspace_mod}${layer_two}"
    monitor_move="${workspace_mod}${layer_two}${layer_three}"

    toggle_float="${tile_mod}${float_key}"
    toggle_stack_global="${tile_mod}${stack_key}"
    toggle_orient_global="${tile_mod}${layer_two}${rotate_key}"

    tile_focus="${tile_mod}"
    tile_move_global="${tile_mod}${layer_two}"

    # Inside management mode
    toggle_manage="${tile_mod}${rotate_key}"
    tile_move=""
    tile_swap="${tile_mod}"
    tile_resize="${layer_two}"
    tile_stack="${stack_key}"
    tile_orient="${rotate_key}"

    KEYS_GNOME_WM=/org/gnome/desktop/wm/keybindings
    KEYS_GNOME_SHELL=/org/gnome/shell/keybindings
    KEYS_MUTTER=/org/gnome/mutter/keybindings
    KEYS_MEDIA=/org/gnome/settings-daemon/plugins/media-keys
    KEYS_MUTTER_WAYLAND_RESTORE=/org/gnome/mutter/wayland/keybindings/restore-shortcuts
    KEYS_POPSHELL=/org/gnome/shell/extensions/pop-shell

    #---   Disable incompatible shortcuts   ---#

    # Restore the keyboard shortcuts: disable <Super>Escape
    dconf write ${KEYS_MUTTER_WAYLAND_RESTORE} "@as []"
    # Hide window: disable <Super>h
    dconf write ${KEYS_GNOME_WM}/minimize "@as ['<Super>comma']"
    # Show the activities overview: disable <Super>s
    dconf write ${KEYS_GNOME_SHELL}/toggle-overview "@as []"
    # Show the quick settings menu: disable <Super>S
    dconf write ${KEYS_GNOME_SHELL}/toggle-quick-settings "@as []"
    # Show the quick settings menu: disable <Super>a
    dconf write ${KEYS_GNOME_SHELL}/toggle-application-view "@as []"
    # Move to monitor up: disable <Super><Shift>Up
    dconf write ${KEYS_GNOME_WM}/move-to-monitor-up "@as []"
    # Move to monitor down: disable <Super><Shift>Down
    dconf write ${KEYS_GNOME_WM}/move-to-monitor-down "@as []"

    # Super + direction keys, move window left and right monitors, or up and down workspaces
    # Move window one monitor to the left
    dconf write ${KEYS_GNOME_WM}/move-to-monitor-left "@as []"
    # Move window one monitor to the right
    dconf write ${KEYS_GNOME_WM}/move-to-monitor-right "@as []"

    # Move window to workspace (up/down specified in popOS shell extension settings)
    dconf write ${KEYS_GNOME_WM}/move-to-workspace-left "['${workspace_move}Left', '${workspace_move}KP_Left', '${workspace_move}${left}']"
    dconf write ${KEYS_GNOME_WM}/move-to-workspace-right "['${workspace_switch}Right', '${workspace_move}KP_Right', '${workspace_move}${right}']"

    # Move view to workspace
    dconf write ${KEYS_GNOME_WM}/switch-to-workspace-down "['${workspace_switch}Down', '${workspace_switch}KP_Down', '${workspace_switch}${down}']"
    dconf write ${KEYS_GNOME_WM}/switch-to-workspace-left "['${workspace_switch}Left', '${workspace_switch}KP_Left', '${workspace_switch}${left}']"
    dconf write ${KEYS_GNOME_WM}/switch-to-workspace-right "['${workspace_switch}Right', '${workspace_switch}KP_Right', '${workspace_switch}${right}']"
    dconf write ${KEYS_GNOME_WM}/switch-to-workspace-up "['${workspace_switch}Up', '${workspace_switch}KP_Up', '${workspace_switch}${up}']"

    # Disable tiling to left / right of screen
    dconf write ${KEYS_MUTTER}/toggle-tiled-left "@as []"
    dconf write ${KEYS_MUTTER}/toggle-tiled-right "@as []"

    # Toggle maximization state
    dconf write ${KEYS_GNOME_WM}/toggle-maximized "['<Super>m']"
    # Lock screen
    dconf write ${KEYS_MEDIA}/screensaver "@as []"
    # Home folder
    dconf write ${KEYS_MEDIA}/home "@as []"
    # Launch email client
    dconf write ${KEYS_MEDIA}/email "@as []"
    # Launch web browser
    dconf write ${KEYS_MEDIA}/www "@as []"
    # Launch terminal
    dconf write ${KEYS_MEDIA}/terminal "@as []"
    # Rotate Video Lock
    dconf write ${KEYS_MEDIA}/rotate-video-lock-static "@as []"

    #---   Configure popOS shell shortcuts   ---#

    # Select active window
    dconf write ${KEYS_POPSHELL}/focus-down "['${tile_focus}Down', '${tile_focus}KP_Down', '${tile_focus}${down}']"
    dconf write ${KEYS_POPSHELL}/focus-left "['${tile_focus}Left', '${tile_focus}KP_Left', '${tile_focus}${left}']"
    dconf write ${KEYS_POPSHELL}/focus-right "['${tile_focus}Right', '${tile_focus}KP_Right', '${tile_focus}${right}']"
    dconf write ${KEYS_POPSHELL}/focus-up "['${tile_focus}Up', '${tile_focus}KP_Up', '${tile_focus}${up}']"

    # Move window between monitors
    dconf write ${KEYS_POPSHELL}/pop-monitor-down "['${monitor_move}Down', '${monitor_move}KP_Down', '${monitor_move}${down}']"
    dconf write ${KEYS_POPSHELL}/pop-monitor-left "['${monitor_move}Left', '${monitor_move}KP_Left', '${monitor_move}${left}']"
    dconf write ${KEYS_POPSHELL}/pop-monitor-right "['${monitor_move}Right', '${monitor_move}KP_Right', '${monitor_move}${right}']"
    dconf write ${KEYS_POPSHELL}/pop-monitor-up "['${monitor_move}Up', '${monitor_move}KP_Up', '${monitor_move}${up}']"

    # Move windows between workspaces (vertical movement handled by Gnome itself)
    dconf write ${KEYS_POPSHELL}/pop-workspace-down "['${workspace_move}Down', '${workspace_move}KP_Down', '${workspace_move}${down}']"
    dconf write ${KEYS_POPSHELL}/pop-workspace-up "['${workspace_move}Up', '${workspace_move}KP_Up', '${workspace_move}${up}']"

    # Move windows in current workspace
    dconf write ${KEYS_POPSHELL}/tile-move-down-global "['${tile_move_global}Down', '${tile_move_global}KP_Down', '${tile_move_global}${down}']"
    dconf write ${KEYS_POPSHELL}/tile-move-right-global "['${tile_move_global}Right', '${tile_move_global}KP_Right', '${tile_move_global}${right}']"
    dconf write ${KEYS_POPSHELL}/tile-move-left-global "['${tile_move_global}Left', '${tile_move_global}KP_Left', '${tile_move_global}${left}']"
    dconf write ${KEYS_POPSHELL}/tile-move-up-global "['${tile_move_global}Up', '${tile_move_global}KP_Up', '${tile_move_global}${up}']"

    # Manage selected window
    dconf write ${KEYS_POPSHELL}/tile-orientation "['${toggle_orient_global}']"
    dconf write ${KEYS_POPSHELL}/toggle-stacking-global "['${toggle_stack_global}']"

    # Don't tile selected window
    dconf write ${KEYS_POPSHELL}/toggle-floating "['${toggle_float}']"

    # Enter into management mode
    dconf write ${KEYS_POPSHELL}/tile-enter "['${toggle_manage}']"

    ### INSIDE MANAGEMENT MODE ###

    # Move windows in management mode
    dconf write ${KEYS_POPSHELL}/tile-move-down "['${tile_move}Down', '${tile_move}KP_Down', '${tile_move}${down}']"
    dconf write ${KEYS_POPSHELL}/tile-move-right "['${tile_move}Right', '${tile_move}KP_Right', '${tile_move}${right}']"
    dconf write ${KEYS_POPSHELL}/tile-move-left "['${tile_move}Left', '${tile_move}KP_Left', '${tile_move}${left}']"
    dconf write ${KEYS_POPSHELL}/tile-move-up "['${tile_move}Up', '${tile_move}KP_Up', '${tile_move}${up}']"

    # Resize windows in management mode
    dconf write ${KEYS_POPSHELL}/tile-resize-down "['${tile_resize}Down', '${tile_resize}KP_Down', '${tile_resize}${down}']"
    dconf write ${KEYS_POPSHELL}/tile-resize-right "['${tile_resize}Right', '${tile_resize}KP_Right', '${tile_resize}${right}']"
    dconf write ${KEYS_POPSHELL}/tile-resize-left "['${tile_resize}Left', '${tile_resize}KP_Left', '${tile_resize}${left}']"
    dconf write ${KEYS_POPSHELL}/tile-resize-up "['${tile_resize}Up', '${tile_resize}KP_Up', '${tile_resize}${up}']"

    # Move focus between windows in management mode
    dconf write ${KEYS_POPSHELL}/tile-swap-down "['${tile_swap}Down', '${tile_swap}KP_Down', '${tile_swap}${down}']"
    dconf write ${KEYS_POPSHELL}/tile-swap-right "['${tile_swap}Right', '${tile_swap}KP_Right', '${tile_swap}${right}']"
    dconf write ${KEYS_POPSHELL}/tile-swap-left "['${tile_swap}Left', '${tile_swap}KP_Left', '${tile_swap}${left}']"
    dconf write ${KEYS_POPSHELL}/tile-swap-up "['${tile_swap}Up', '${tile_swap}KP_Up', '${tile_swap}${up}']"

    # Manage selected window in management mode
    dconf write ${KEYS_POPSHELL}/management-orientation "['${tile_orient}']"
    dconf write ${KEYS_POPSHELL}/toggle-stacking "['${tile_stack}']"
}

custom_defaults() {
    if defaults_changed; then
        return 0
    fi

    POPSHELL=/org/gnome/shell/extensions/pop-shell

    dconf write ${POPSHELL}/active-hint false
    dconf write ${POPSHELL}/gap-inner 4
    dconf write ${POPSHELL}/gap-outer 4
    dconf write ${POPSHELL}/mouse-cursor-follows-active-window false
    dconf write ${POPSHELL}/show-title false
    dconf write ${POPSHELL}/smart-gaps false
    dconf write ${POPSHELL}/snap-to-grid true
    dconf write ${POPSHELL}/tile-by-default true
}

if ! command -v gnome-extensions >/dev/null; then
    echo 'You must install gnome-extensions to configure or enable via this script'
    echo '(`gnome-shell` on Debian systems, `gnome-extensions` on openSUSE systems.)'
    exit 1
fi

set_keybindings

custom_defaults

# Make sure user extensions are enabled
dconf write /org/gnome/shell/disable-user-extensions false

# Use a window placement behavior which works better for tiling

if gnome-extensions list | grep native-window; then
    gnome-extensions enable $(gnome-extensions list | grep native-window)
fi

# Workspaces spanning displays works better with Pop Shell
dconf write /org/gnome/mutter/workspaces-only-on-primary false

# Disable tile when dragging to screen edges
dconf write /org/gnome/mutter/edge-tiling false
