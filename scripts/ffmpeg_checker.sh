#!/usr/bin/env bash

if [[ -z "${1}" ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIR="$1"
ok=0
ng=0

for f in "${DIR}"/*.{mp4,mkv}; do
    [[ -e "${f}" ]] || continue
    echo "[checking] ${f##*/}"
    if ffmpeg -v error -i "${f}" -f null - 2>&1; then
        echo "OK"
        (( ok++ ))
    else
        echo "NG"
        (( ng++ ))
    fi
done

echo ""
echo "OK: ${ok}  NG: ${ng}"
