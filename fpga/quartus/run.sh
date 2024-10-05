#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

cd ${BASEDIR}/fpga/quartus

if [ "$SYNTHESIS" = "1" ]
then
  ${QUARTUS}_map top.qsf
  ${QUARTUS}_fit --read_settings_files=off --write_settings_files=off top
  ${QUARTUS}_sta top
  ${QUARTUS}_asm top
fi

if pgrep -x "jtagd" > /dev/null
then
  sudo killall jtagd
fi
sudo $JTAGCONFIG
${QUARTUS}_pgm -m jtag -o "p;${BASEDIR}/fpga/quartus/output_files/top.sof"