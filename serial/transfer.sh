#!/bin/bash
set -e

start=`date +%s`

$PYTHON $BASEDIR/serial/transfer.py $SERIAL $BASEDIR/build/$PROGRAM/elf/$PROGRAM.bin

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
