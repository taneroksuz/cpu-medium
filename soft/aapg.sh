#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export ITER=$4
export PYTHON=$5
export OFFSET=$6
export BASEDIR=$7
export AAPG=$8
export CONFIG=$9

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/aapg

mkdir ${BASEDIR}/build/aapg

mkdir ${BASEDIR}/build/aapg/elf
mkdir ${BASEDIR}/build/aapg/dump
mkdir ${BASEDIR}/build/aapg/coe
mkdir ${BASEDIR}/build/aapg/dat
mkdir ${BASEDIR}/build/aapg/mif
mkdir ${BASEDIR}/build/aapg/hex

if [ ! -d "${BASEDIR}/soft/src/aapg/setup" ]; then
  mkdir ${BASEDIR}/soft/src/aapg/setup
fi

cd ${BASEDIR}/soft/src/aapg/setup
${AAPG} setup

cp ${BASEDIR}/soft/src/aapg/${CONFIG}.yaml ${BASEDIR}/soft/src/aapg/setup/config.yaml
${AAPG} gen --arch rv32

make -f ${BASEDIR}/soft/src/aapg/Makefile || exit

shopt -s nullglob
for filename in ${BASEDIR}/build/aapg/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/aapg
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/aapg
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/aapg
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/aapg
done

shopt -s nullglob
for filename in ${BASEDIR}/build/aapg/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/aapg/dump/
done
