#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Fewtarius

INSTALLPATH="/storage/roms/ports"
PKG_NAME="cannonball"
PKG_FILE="351ELEC-Packages-cannonball.zip"
PKG_VERSION="1.0"
PKG_SHASUM=""
SOURCEPATH=$(pwd)



### Test and make the full path if necessary.
if [ ! -d "${INSTALLPATH}/${PKG_NAME}" ]
then
  mkdir -p "${INSTALLPATH}/${PKG_NAME}"
fi

cd ${INSTALLPATH}/${PKG_NAME}

curl -Lo ${PKG_FILE} https://github.com/anthonycaccese/351ELEC-Packages/releases/download/${PKG_VERSION}/${PKG_FILE}
BINSUM=$(sha256sum ${PKG_FILE} | awk '{print $1}')
if [ ! "${PKG_SHASUM}" == "${BINSUM}" ]
then
  echo "Checksum mismatch, please update the package."
  exit 1
fi

unzip -o ${PKG_FILE}
rm ${PKG_FILE}



### Create the start script
cat <<EOF >${INSTALLPATH}/"Cannonball.sh"
. /etc/profile

/usr/bin/runemu.sh "/storage/roms/ports/cannonball/" -Pports "${2}" -Ccannonball "-SC${0}" &>>/tmp/logs/exec.log

ret_error=$?

[[ "$ret_error" != 0 ]] && ee_check_bios "Cannonball"

exit $ret_error

EOF



### Add images if they are missing
if [ ! -d "${INSTALLPATH}/images" ]
then
  mkdir -p "${INSTALLPATH}/images"
fi

for image in system-cannonball.png  system-cannonball-thumb.png
do
  cp "${SOURCEPATH}/${PKG_NAME}/${image}" "${INSTALLPATH}/images"
done



### Add video if its missing
if [ ! -d "${INSTALLPATH}/videos" ]
then
  mkdir -p "${INSTALLPATH}/videos"
fi

for video in system-cannonball.mp4
do
  cp "${SOURCEPATH}/${PKG_NAME}/${video}" "${INSTALLPATH}/videos"
done



### Add cannonball to the game list
if [ ! "$(grep -q 'Cannonball' ${INSTALLPATH}/gamelist.xml)" ]
then
	### Add to the game list
	xmlstarlet ed --omit-decl --inplace \
		-s '//gameList' -t elem -n 'game' \
		-s '//gameList/game[last()]' -t elem -n 'path'           -v './Cannonball.sh'\
		-s '//gameList/game[last()]' -t elem -n 'name'           -v 'Cannonball'\
		-s '//gameList/game[last()]' -t elem -n 'desc'           -v 'This is an arcade-perfect port of SEGAs seminal arcade racer. Features include: Pixel-perfect 240p video. 60 FPS gameplay. Continuous mode (play all 15 tracks in one go).'\
		-s '//gameList/game[last()]' -t elem -n 'image'          -v './images/system-cannonball.png'\
		-s '//gameList/game[last()]' -t elem -n 'thumbnail'      -v './images/system-cannonball-thumb.png'\
        -s '//gameList/game[last()]' -t elem -n 'video'          -v './videos/system-cannonball.mp4'\
		-s '//gameList/game[last()]' -t elem -n 'genre'          -v 'Driving'\
		-s '//gameList/game[last()]' -t elem -n 'players'        -v '1'\
		-s '//gameList/game[last()]' -t elem -n 'rating'         -v '0.8'\
		-s '//gameList/game[last()]' -t elem -n 'releasedate'    -v '20140101T000000'\
		-s '//gameList/game[last()]' -t elem -n 'developer'      -v 'Chris White, Yu Suzuki'\
		-s '//gameList/game[last()]' -t elem -n 'publisher'      -v 'Non-commercial'\
		${INSTALLPATH}/gamelist.xml
fi