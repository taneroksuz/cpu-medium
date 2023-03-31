#!/bin/bash
set -e

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

cd $BASEDIR/sim/work

declare -A benchmark=([aapg]=1 [bootloader]=1 [coremark]=1 [csmith]=1 [dhrystone]=1 [riscv-dv]=1 [sram]=1 [timer]=1 [whetstone]=1)
declare -A verification=([compliance]=1 [isa]=1)

start=`date +%s`
if [ "$WAVE" = 'on' ]
then
  ${VERILATOR} --cc -Wno-UNOPTFLAT -Wno-UNSIGNED --trace -trace-max-array 128 --trace-structs -f $BASEDIR/sim/files.f --top-module soc --exe $BASEDIR/sim/run.cpp 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
else
  ${VERILATOR} --cc -Wno-UNOPTFLAT -Wno-UNSIGNED -f $BASEDIR/sim/files.f --top-module soc --exe $BASEDIR/sim/run.cpp 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
fi
if [[ -n "${benchmark[$PROGRAM]}" ]]
then
  cp $BASEDIR/build/$PROGRAM/dat/$PROGRAM.dat bram.dat
  cp $BASEDIR/build/$PROGRAM/elf/$PROGRAM.host host.dat
  obj_dir/Vsoc $MAXTIME $PROGRAM.vcd
elif [[ -n "${verification[$PROGRAM]}" ]]
then
  for filename in $BASEDIR/build/$PROGRAM/dat/*.dat; do
    filename=${filename##*/}
    filename=${filename%.dat}
    echo "$filename"
    cp $BASEDIR/build/$PROGRAM/dat/$filename.dat bram.dat
    cp $BASEDIR/build/$PROGRAM/elf/$filename.host host.dat
    obj_dir/Vsoc $MAXTIME $filename.vcd
  done
else
  subpath=${PROGRAM%/dat*}
  filename=${PROGRAM##*/}
  filename=${filename%.dat}
  cp $BASEDIR/$subpath/dat/$filename.dat bram.dat
  cp $BASEDIR/$subpath/elf/$filename.host host.dat
  obj_dir/Vsoc $MAXTIME $filename.vcd
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
