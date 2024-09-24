#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

export PROJECT=top
export QUARTUS_VER=23.1
export QUARTUS_BIN=$HOME/intelFPGA_lite/${QUARTUS_VER}std/quartus/bin/

cd ${BASEDIR}/fpga/quartus

${QUARTUS_BIN}quartus_map ${PROJECT}.qsf
${QUARTUS_BIN}quartus_fit --read_settings_files=off --write_settings_files=off ${PROJECT}
${QUARTUS_BIN}quartus_sta ${PROJECT}
${QUARTUS_BIN}quartus_asm ${PROJECT}

printf "${RED}"
awk '/^Total logic elements : / {le=$5} \
      /^    Total combinational functions : / {lut=$5} \
      /^    Dedicated logic registers : / {dff=$5} \
      END {
        gsub(/,/, "", le);
        gsub(/,/, "", lut);
        gsub(/,/, "", dff);
        printf("SYNTHESIS RESULTS: %s slices, %s LUTs, %s DFFs, ", \
          le, lut, dff)}' \
    < ${BASEDIR}/fpga/quartus/output_files/${PROJECT}.fit.summary
awk '/; Slow 1200mV 85C Model Fmax Summary/,/; Slow 1200mV 85C Model Setup Summary/ {
        if ($8=="CLOCK_50_B5B") {mhz=$2} \
      } \
      END {
        printf("%s MHz\n", mhz)}' \
    < ${BASEDIR}/fpga/quartus/output_files/${PROJECT}.sta.rpt
printf "${NC}"

sudo killall jtagd
sudo ${QUARTUS_BIN}/jtagconfig
${QUARTUS_BIN}/quartus_pgm -m jtag -o "p;${BASEDIR}/fpga/quartus/build/output_files/${PROJECT}.sof"