#!/bin/bash
set -e

export RISCV=$1
export MARCH=$2
export MABI=$3
export PYTHON=$4
export OFFSET=$5
export BASEDIR=$6

cd $BASEDIR/tools/riscv-torture/
sbt generator/run > /dev/null
cd -

RISCV_GCC=$RISCV/riscv32-unknown-elf-gcc
RISCV_GCC_OPTS="-march=$MARCH -mabi=$MABI -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf"
RISCV_LINK_OPTS="-static -nostdlib -nostartfiles -lm -lgcc -T $BASEDIR/tools/riscv-torture/env/p/link.ld"
RISCV_OBJDUMP="$RISCV/riscv32-unknown-elf-objdump -Mnumeric,no-aliases --disassemble --disassemble-zeroes"
RISCV_OBJCOPY="$RISCV/riscv32-unknown-elf-objcopy -O binary"
RISCV_INCL="-I $BASEDIR/soft/src/common -I $BASEDIR/soft/src/env"
RISCV_SRC="$BASEDIR/tools/riscv-torture/output/test.S"

ELF2COE=$BASEDIR/soft/py/elf2coe.py
ELF2DAT=$BASEDIR/soft/py/elf2dat.py
ELF2MIF=$BASEDIR/soft/py/elf2mif.py
ELF2HEX=$BASEDIR/soft/py/elf2hex.py

if [ ! -d "${BASEDIR}/build" ]; then
  mkdir ${BASEDIR}/build
fi

rm -rf ${BASEDIR}/build/torture

mkdir ${BASEDIR}/build/torture

mkdir ${BASEDIR}/build/torture/elf
mkdir ${BASEDIR}/build/torture/dump
mkdir ${BASEDIR}/build/torture/coe
mkdir ${BASEDIR}/build/torture/dat
mkdir ${BASEDIR}/build/torture/mif
mkdir ${BASEDIR}/build/torture/hex

$RISCV_GCC $RISCV_GCC_OPTS $RISCV_LINK_OPTS -o ${BASEDIR}/build/torture/elf/torture.elf $RISCV_SRC $RISCV_INCL
$RISCV_OBJCOPY ${BASEDIR}/build/torture/elf/torture.elf ${BASEDIR}/build/torture/elf/torture.bin
$RISCV_OBJDUMP ${BASEDIR}/build/torture/elf/torture.elf > ${BASEDIR}/build/torture/dump/torture.dump

shopt -s nullglob
for filename in ${BASEDIR}/build/torture/elf/*.elf; do
  echo $filename
  ${PYTHON} ${ELF2COE} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/torture
  ${PYTHON} ${ELF2DAT} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/torture
  ${PYTHON} ${ELF2MIF} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/torture
  ${PYTHON} ${ELF2HEX} ${filename} 0x0 ${OFFSET} ${BASEDIR}/build/torture
done

shopt -s nullglob
for filename in ${BASEDIR}/build/torture/elf/*.dump; do
  mv ${filename} ${BASEDIR}/build/torture/dump/
done
