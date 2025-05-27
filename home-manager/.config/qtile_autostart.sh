#!/bin/sh

feh --bg-scale /home/eeshta/Pictures/eeshta_wallpaper.png &
picom -b &
killall -q polybar &
polybar &
# xrandr --output --mode 2560x1440
