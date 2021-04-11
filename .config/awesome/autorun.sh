#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

## run (only once) processes which spawn with different names
if (command -v  xfce4-power-manager && ! pgrep xfce4-power-man) ; then
    xfce4-power-manager &
fi

run xfsettingsd
run light-locker
run thunar --daemon

run nm-applet
run pa-applet

run picom
