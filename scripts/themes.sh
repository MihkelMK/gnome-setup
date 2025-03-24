#!/bin/bash

CUSTOM_FONT="$1"
DCONF_INTERFACE=/org/gnome/desktop/interface

read -rp "Set theme to (d)ark or (l)ight: " choice
case "$choice" in
l | L)
  echo "Light mode selected"
  export DARK_MODE=false
  ;;
d | D)
  echo "Dark mode selected"
  export DARK_MODE=true
  ;;
*) echo "invalid" ;;
esac

if $DARK_MODE; then
  dconf write ${DCONF_INTERFACE}/color-scheme "'prefer-dark'"
  export GTK_THEME='adw-gtk3-dark'
  export QT_THEME="kvantum-dark"
  export KVANTUM_THEME="KvLibadwaitaDark"
  export ICON_THEME="Colloid-dark"
else
  dconf write ${DCONF_INTERFACE}/color-scheme "'default'"
  export GTK_THEME='adw-gtk3'
  export QT_THEME="kvantum"
  export KVANTUM_THEME="KvLibadwaita"
  export ICON_THEME="Colloid"
fi

FONT_FIXED="Adwaita Mono"
if $CUSTOM_FONT; then
  export FONT_GENERAL="Fira Sans"
else
  export FONT_GENERAL="Adwaita Sans"
fi

QT5_CONF_PATH="$HOME/.config/qt5ct"
QT5_FONT_SUFFIX=",11,-1,5,50,0,0,0,0,0"
FONT_FIXED_QT5="$FONT_FIXED$QT5_FONT_SUFFIX"
FONT_GENERAL_QT5="$FONT_GENERAL$QT5_FONT_SUFFIX"

QT6_CONF_PATH="$HOME/.config/qt6ct"
QT6_FONT_SUFFIX=",11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
FONT_FIXED_QT6="$FONT_FIXED$QT6_FONT_SUFFIX"
FONT_GENERAL_QT6="$FONT_GENERAL$QT6_FONT_SUFFIX"

# Change icon theme
if [ "$(dconf read ${DCONF_INTERFACE}/icon-theme)" != "'$ICON_THEME'" ]; then
  echo "Setting icon theme to '$ICON_THEME'"
  dconf write ${DCONF_INTERFACE}/icon-theme "'${ICON_THEME}'"
fi

# Theme GTK3 apps
if [ "$(dconf read ${DCONF_INTERFACE}/gtk-theme)" != "'$GTK_THEME'" ]; then
  echo "Setting GTK3 theme to '$GTK_THEME'"
  dconf write ${DCONF_INTERFACE}/gtk-theme "'${GTK_THEME}'"
fi

# Make Qt5/Qt6 apps use qt5ct/qt6ct
echo ""
echo "Adding QT_WAYLAND_DECORATION and QT_QPA_PLATFORMTHEME to /etc/profile"
printf "# added by gnome-setup script start\nexport QT_WAYLAND_DECORATION=adwaita\nexport QT_QPA_PLATFORMTHEME=qt5ct\n# added by gnome-setup script end\n" | sudo tee -a /etc/profile >/dev/null
echo

# Update qt5ct.conf
if [ -f "$QT5_CONF_PATH/qt5ct.conf" ]; then
  echo "Backing up qt5ct conf to $QT5_CONF_PATH/qt5ct.conf.bak"
  mv "$QT5_CONF_PATH/qt5ct.conf" "$QT5_CONF_PATH/qt5ct.conf.bak"
fi

cp configs/qtct.conf "$QT5_CONF_PATH/qt5ct.conf" &&
  sed -i "s|path_placeholder|$QT5_CONF_PATH|g" "$QT5_CONF_PATH/qt5ct.conf" &&
  sed -i "s/icon_placeholder/$ICON_THEME/g" "$QT5_CONF_PATH/qt5ct.conf" &&
  sed -i "s/style_placeholder/$QT_THEME/g" "$QT5_CONF_PATH/qt5ct.conf" &&
  sed -i "s/fixed_font_placeholder/$FONT_FIXED_QT5/g" "$QT5_CONF_PATH/qt5ct.conf" &&
  sed -i "s/general_font_placeholder/$FONT_GENERAL_QT5/g" "$QT5_CONF_PATH/qt5ct.conf"
echo "qt5ct.conf updated"

# Update qt6ct.conf
if [ -f "$QT6_CONF_PATH/qt6ct.conf" ]; then
  echo "Backing up qt6ct conf to $QT6_CONF_PATH/qt6ct.conf.bak"
  mv "$QT6_CONF_PATH/qt6ct.conf" "$QT6_CONF_PATH/qt6ct.conf.bak"
fi

cp configs/qtct.conf "$QT6_CONF_PATH/qt6ct.conf" &&
  sed -i "s|path_placeholder|$QT6_CONF_PATH|g" "$QT6_CONF_PATH/qt6ct.conf" &&
  sed -i "s/icon_placeholder/$ICON_THEME/g" "$QT6_CONF_PATH/qt6ct.conf" &&
  sed -i "s/style_placeholder/$QT_THEME/g" "$QT6_CONF_PATH/qt6ct.conf" &&
  sed -i "s/fixed_font_placeholder/$FONT_FIXED_QT6/g" "$QT6_CONF_PATH/qt6ct.conf" &&
  sed -i "s/general_font_placeholder/$FONT_GENERAL_QT6/g" "$QT6_CONF_PATH/qt6ct.conf"
echo "qt6ct.conf updated"

# Set theme in Kvantum conf
if [ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]; then
  echo "Backing up Kvantum conf to $HOME/.config/Kvantum/kvantum.kvconfig.bak"
  mv "$HOME/.config/Kvantum/kvantum.kvconfig" "$HOME/.config/Kvantum/kvantum.kvconfig.bak"
fi
printf "[General]\ntheme=%s\n" "$KVANTUM_THEME" >"$HOME/.config/Kvantum/kvantum.kvconfig"

echo "kvantum.kvconfig updated"
