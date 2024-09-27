#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

cd ${BASEDIR}/fpga/quartus

${QUARTUS_BIN}quartus_map top.qsf
${QUARTUS_BIN}quartus_fit --read_settings_files=off --write_settings_files=off top
${QUARTUS_BIN}quartus_sta top
${QUARTUS_BIN}quartus_asm top

if pgrep -x "jtagd" > /dev/null
then
  sudo killall jtagd
fi
sudo ${QUARTUS_BIN}/jtagconfig
${QUARTUS_BIN}/quartus_pgm -m jtag -o "p;${BASEDIR}/fpga/quartus/output_files/top.sof"