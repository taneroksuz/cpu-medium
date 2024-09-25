#!/bin/bash
set -e

start=`date +%s`

SIZE=0x80000

${RISCV}/bin/riscv32-unknown-elf-objcopy -O binary $BASEDIR/serial/input/program.riscv $BASEDIR/serial/input/program.bin
$PYTHON $BASEDIR/serial/transfer.py $SERIAL $BASEDIR/serial/input/program.bin $SIZE
rm $BASEDIR/serial/input/program.bin

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
