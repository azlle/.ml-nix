#!/usr/bin/env bash
NOTIFY_ID=868

case $1 in
    +) amixer set Master 5%+ unmute > /dev/null ;;
    -) amixer set Master 5%- unmute > /dev/null ;;
    m) amixer set Master toggle > /dev/null ;;
esac

# 一度のamixer実行で両方取得
output=$(amixer get Master)
vol=$(echo "$output" | grep -oP '\[\d+%\]' | head -1 | tr -d '[]%')
muted=$(echo "$output" | grep -o '\[off\]' | head -1)

[ "$muted" = "[off]" ] && \
    dunstify -t 1500 -r $NOTIFY_ID -h int:value:0 "🔇 ミュート" || \
    dunstify -t 1500 -r $NOTIFY_ID -h int:value:$vol "🔊 音量: ${vol}%"
