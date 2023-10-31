#!/bin/bash
set -e

start=`date +%s`

$RISCV-objcopy -O binary $BASEDIR/serial/input/program.elf $BASEDIR/serial/input/program.bin
$PYTHON $BASEDIR/serial/transfer.py $SERIAL $BASEDIR/serial/input/program.bin

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
