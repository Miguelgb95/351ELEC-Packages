#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Fewtarius

INSTALLPATH="/storage/roms/ports"
PKG_NAME="cannonball"

rm -rf "${INSTALLPATH}/${PKG_NAME}"
rm -f "${INSTALLPATH}/Cannonball.sh"

for image in system-cannonball.png  system-cannonball-thumb.png
do
  rm "${INSTALLPATH}/images/${image}"
done

for video in system-cannonball.mp4
do
  rm "${INSTALLPATH}/videos/${video}"
done