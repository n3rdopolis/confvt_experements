#! /bin/bash
#This calls cage and vte in a way that can be called as init (like a recovery console)
#Probably wont work in an initrd, libraries would be too big

mkdir -p /run/user/0
chmod 700 /run/user/0
export XDG_RUNTIME_DIR=/run/user/0
export XDG_SEAT=notty
. /usr/bin/wlruntime_vars

modprobe evdev

if [[ $$ == 1 ]]
then
  echo "/sbin/init" > /run/initcmd
fi

mkdir -p /run/udev/data

#The display server, and all devices get assigned to the notty seat, to prevent the usage of TTYs

find /sys/class/input/event* | while read Device
do
  read MAJMIN < $Device/dev
  echo "E:ID_INPUT=1"$'\n'"E:ID_INPUT_KEY=1"$'\n'"E:ID_INPUT_KEYBOARD=1"$'\n'"E:ID_INPUT_MOUSE=1"$'\n'"E:ID_SEAT=notty" > /run/udev/data/c$MAJMIN
done

find /sys/class/drm/*/dev | while read Device
do
  read MAJMIN < $Device
  echo "E:ID_SEAT=notty" > /run/udev/data/c$MAJMIN
done


cage -d -s -- \
vte --no-context-menu --no-builtin-dingus --reverse --font=10 --no-hyperlink --cursor-shape=underline --blink=always --encoding=utf8 --scrollback-lines=10000 --no-scrollbar --no-decorations -- \
bash &> /dev/null

if [[ $$ == 1 ]]
then
  read INITCMD < /run/initcmd
  rm /run/initcmd
  exec $INITCMD
fi
