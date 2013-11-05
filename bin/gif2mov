#!/usr/bin/env bash
# Usage: gif2mov INPUT.gif [OUTPUT.mov [<fps>]]
#
# Convert an animated GIF into a video suitable for embedding where GIFs are
# not supported.
#
# Features:
# - auto-detection of the framerate unless explicitly overriden via <fps>
# - un-optimizes GIFs that have frames of variable dimensions
# - ensures that GIF height is divisible by 2 (video encoder limitation)
#
# Limitations:
# - variable delays between GIF frames will be lost
#
# Requirements:
# - Gifsicle 1.61
# - ffmpeg 1.1
set -e

gif="${1?}"
out="${2}"
[ -n "$out" ] || out="${gif%.gif}.mov"
framerate="${3}"

tmp_dir="${TMPDIR:-/tmp}/gif2mov"
tmp_name="$tmp_dir/$$"

# Output width, height & delay of the first frame
gif_info() {
  gifsicle -I "$1" '#0' | awk '
    BEGIN { ORS = " " }
    /screen/ { s=$(NF); sub("x", ORS, s); print s }
    /delay/ { d=$(NF); sub("s", "", d); print d }
  '
}

explode_options="--explode --unoptimize"
info=( $(gif_info "$gif") )
height="${info[1]}"
[ -n "$framerate" ] || framerate="1/${info[2]}"

if [ "$((height % 2))" -eq 1 ]; then
  # Crop 1px from the bottom of the GIF to ensure height is divisible by 2
  explode_options="$explode_options --crop 0,0+0x-1"
fi

mkdir -p "$tmp_dir"

gifsicle $explode_options "$gif" -o "$tmp_name"
find "$tmp_dir" -name "$$.*" -exec mv {} {}.gif \;

ffmpeg -loglevel warning \
  -i "${tmp_name}.%03d.gif" \
  -r "$framerate" -y "$out"

rm -rf "$tmp_dir"/*
