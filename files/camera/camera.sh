#!/sbin/sh

# This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
# The Open GApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Functions & variables
tmp_path=/tmp

file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

rom_build_prop=/system/build.prop

arch=$(file_getprop $rom_build_prop "ro.product.cpu.abi=")

prod_dev=$(file_getprop $rom_build_prop "ro.product.device")

# GoogleCamera
if (echo "$arch" | grep -qi "armeabi"); then
  if (echo "$prod_dev" | grep -qi "shamu"); then
    cp -rf $tmp_path/camera/arm/* /system
  elif (echo "$prod_dev" | grep -qi "hammerhead"); then
    cp -rf $tmp_path/camera/arm/* /system
  fi
elif (echo "$arch" | grep -qi "arm64"); then
  cp -rf $tmp_path/camera/arm64/* /system
fi

# Camera framework
if (echo "$prod_dev" | grep -qi "angler"); then
  cp -rf $tmp_path/camera/experimental/* /system
elif (echo "$prod_dev" | grep -qi "bullhead"); then
  cp -rf $tmp_path/camera/experimental/* /system
elif (echo "$prod_dev" | grep -qi "hammerhead"); then
  cp -rf $tmp_path/camera/camera2/* /system
fi

# Cleanup
rm -rf /tmp/camera
