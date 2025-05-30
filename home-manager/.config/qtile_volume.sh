#!/bin/sh

NOTIFY_ID=868

case $1 in
    +)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;
    -)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    m)
        pactl set-sink-mute @DEFAULT_SINK@ toggle

        MUTED=`pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes'`
        if [ "$MUTED" = "yes" ]; then
            dunstify -t 1500 -r $NOTIFY_ID -h int:value:0 "🔇 ミュート"
        else
            VOL=`pactl get-sink-volume @DEFAULT_SINK@ | sed 's/.*\([0-9][0-9]*\)%.*/\1/' | head -1`
            dunstify -t 1500 -r $NOTIFY_ID -h int:value:$VOL "🔊 音量: ${VOL}%"
        fi
        exit 0
        ;;
esac

VOL=`pactl get-sink-volume @DEFAULT_SINK@ | sed 's/.*\([0-9][0-9]*\)%.*/\1/' | head -1`
dunstify -t 1500 -r $NOTIFY_ID -h int:value:$VOL "🔊 ${VOL}%"
