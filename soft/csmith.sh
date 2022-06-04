#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export GCC=$4
export CSMITH=$5
export CSMITH_INCL=$6
export PYTHON=$7
export OFFSET=$8
export BASEDIR=$9

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

cd ${BASEDIR}/soft/src/csmith
${CSMITH}/bin/csmith --no-packed-struct -o csmith.c
cd -

rm -rf ${BASEDIR}/build/csmith

mkdir ${BASEDIR}/build/csmith

mkdir ${BASEDIR}/build/csmith/elf
mkdir ${BASEDIR}/build/csmith/dump
mkdir ${BASEDIR}/build/csmith/coe
mkdir ${BASEDIR}/build/csmith/dat
mkdir ${BASEDIR}/build/csmith/mif
mkdir ${BASEDIR}/build/csmith/hex
mkdir ${BASEDIR}/build/csmith/checksum

RED='\033[0;31m'
NC='\033[0m'

make -f ${BASEDIR}/soft/src/csmith/Makefile > /tmp/csmith 2>&1
if [ "$?" -ne 0 ]; then
  echo -e "${RED}Build failed.Please run again!${NC}"
  exit 0
fi

chmod +x ${BASEDIR}/soft/src/csmith/csmith.o
timeout 10 ${BASEDIR}/soft/src/csmith/csmith.o | tee ${BASEDIR}/build/csmith/checksum/csmith.checksum
if [ "$?" -ne 0 ]; then
  echo -e "${RED}Timeout.Please run again!${NC}"
  exit 0
fi

shopt -s nullglob
for filename in ${BASEDIR}/build/csmith/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/csmith
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/csmith
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/csmith
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/csmith
done

shopt -s nullglob
for filename in ${BASEDIR}/build/csmith/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/csmith/dump/
done
