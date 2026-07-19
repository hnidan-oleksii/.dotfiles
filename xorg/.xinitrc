#!/bin/sh
export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_TYPE=x11
systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
xrdb -merge ~/.Xresources
exec dwm
