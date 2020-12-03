#! /bin/bash
#
#Start Weston or other dislay servers with this specify weston as an argument
#This is how to start a new display server when there are no TTYs
export XDG_SESSION_ID=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session Id | awk -F \" '{print $2}')
export XDG_SEAT=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session Seat | awk -F \" '{print $2}')

SeatCanTTY=$(loginctl show-seat $XDG_SEAT -p CanTTY --value)
if ($SeatCanTTY == yes)
{
  echo "Not supported on seats with TTYs"
  exit 1
} 
systemd-run --wait --setenv=XDG_SEAT=$XDG_SEAT -p PAMName=user -p User=$LOGNAME "$@"
loginctl activate $XDG_SESSION_ID 

