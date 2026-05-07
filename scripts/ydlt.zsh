#!/usr/bin/env zsh

zparseopts -D -E n=USE_NIX

if [[ -z "${1}" ]]; then
    print -u2 "Usage: $0 <URL_file> [-n]"
    exit 1
fi

if (( ${#USE_NIX} )); then
    YT_DLP=(nix run --refresh nixpkgs/nixpkgs-unstable#yt-dlp --)
else
    YT_DLP=(yt-dlp)
fi

readonly URL_FILE="$1"
readonly SLEEP_STEP=5
readonly MAX_RETRIES=3
readonly TOTAL=$(grep -c '^https\?://' "${URL_FILE}" 2>/dev/null || print 0)
integer CURRENT=0 SUCCESS=0 WAIT=0

while IFS= read -r URL || [[ -n "${URL}" ]]; do
    [[ -z "${URL}" || "${URL}" == '#'* ]] && continue

    (( CURRENT++ ))
    print "[${CURRENT}/${TOTAL}] ${URL}"

    SUCCESS=0
    for (( ATTEMPT=1; ATTEMPT<=MAX_RETRIES; ATTEMPT++ )); do
        WAIT=$(( ATTEMPT * SLEEP_STEP ))
        print "[Attempt ${ATTEMPT}/${MAX_RETRIES} — sleeping ${WAIT}s] ${URL}"
        sleep "${WAIT}"

        if "${YT_DLP[@]}" \
                -f 'bv*+ba/b' \
                --merge-output-format mkv \
                --postprocessor-args 'Merger:-c:a pcm_s16le' \
                "${URL}"; then
            SUCCESS=1
            break
        fi
    done

    (( SUCCESS )) || print "[Skipped] ${URL}"

done < "${URL_FILE}"
