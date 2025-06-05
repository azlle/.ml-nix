#!/usr/bin/env bash
feh --bg-scale /home/eeshta/Pictures/eeshta_wallpaper.png &

picom -b &

pkill -x polybar
sleep 0.5
polybar &

fcitx5 -d --replace &
# xrandr --output --mode 2560x1440

discordcanary --start-minimized &
