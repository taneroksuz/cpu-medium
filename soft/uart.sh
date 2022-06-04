#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export ITER=$4
export PYTHON=$5
export OFFSET=$6 # 0x4000
export BASEDIR=$7

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/uart

mkdir ${BASEDIR}/build/uart

mkdir ${BASEDIR}/build/uart/elf
mkdir ${BASEDIR}/build/uart/dump
mkdir ${BASEDIR}/build/uart/coe
mkdir ${BASEDIR}/build/uart/dat
mkdir ${BASEDIR}/build/uart/mif
mkdir ${BASEDIR}/build/uart/hex

make -f ${BASEDIR}/soft/src/uart/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/uart/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/uart
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/uart
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/uart
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/uart
done

shopt -s nullglob
for filename in ${BASEDIR}/build/uart/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/uart/dump/
done
