#!/bin/sh
# Usage: colordump [-b]
set -e

if [ "$1" = "-b" ]; then
  mode=40
  text=""
else
  mode=30
  text="ag"
fi

printf "\n"
printf "  %2d  " $mode
for i in $(seq 0 7); do
  printf "\e[%d;%dm%2s\e[m " 0 $((mode + i)) "$text"
done
printf "\n\n"
printf "1;%2d  " $mode
for i in $(seq 0 7); do
  printf "\e[%d;%dm%2s\e[m " 1 $((mode + i)) "$text"
done
printf "\n"

show() {
  printf "\e[%d;5;%dm%2s\e[m " $((mode+8)) $1 "$text"
}

printf "\n   +  "
for i in $(seq 0 35); do
  printf "%2b " $i
done

printf "\n\n %3d  " 0
for i in $(seq 0 15); do
  show $i
done

for i in $(seq 0 6); do
  i=$(( i*36 + 16 ))
  printf "\n\n %3d  " $i
  for j in $(seq 0 35); do
    val=$(( i+j ))
    [ "$val" -le 255 ] || break
    show $val
  done
done

printf "\n\n"
