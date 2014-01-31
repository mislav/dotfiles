#!/bin/sh
# Usage: steal <YOUTUBE-URL>
# Requirements: youtube-dl, ffmpeg
set -e

# strip the YouTube playlist
url="${1%%&*}"

if [ -z "$url" ]; then
  echo "no URL given" >&2
  exit 1
fi

youtube-dl --no-mtime -xo '/tmp/%(title)s.%(ext)s' "$url"
shopt -s nullglob
mv "$(ls -t /tmp/*.{m4a,mp3,mp4} | head -1)" \
  "$HOME/Music/iTunes/iTunes Media/Automatically Add to iTunes/"
