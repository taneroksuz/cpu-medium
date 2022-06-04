#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export ITER=$4
export PYTHON=$5
export OFFSET=$6
export BASEDIR=$7

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/dhrystone

mkdir ${BASEDIR}/build/dhrystone

mkdir ${BASEDIR}/build/dhrystone/elf
mkdir ${BASEDIR}/build/dhrystone/dump
mkdir ${BASEDIR}/build/dhrystone/coe
mkdir ${BASEDIR}/build/dhrystone/dat
mkdir ${BASEDIR}/build/dhrystone/mif
mkdir ${BASEDIR}/build/dhrystone/hex

make -f ${BASEDIR}/soft/src/dhrystone/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/dhrystone/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/dhrystone
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/dhrystone
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/dhrystone
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/dhrystone
done

shopt -s nullglob
for filename in ${BASEDIR}/build/dhrystone/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/dhrystone/dump/
done
