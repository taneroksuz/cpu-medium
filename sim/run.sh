#!/bin/bash
set -e

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

cd $BASEDIR/sim/work

declare -A benchmark=([aapg]=1 [bootloader]=1 [coremark]=1 [csmith]=1 [dhrystone]=1 [riscv-dv]=1 [sram]=1 [timer]=1 [whetstone]=1)
declare -A verification=([compliance]=1 [isa]=1)

start=`date +%s`
if [ "$WAVE" = 'on' ]
then
  ${VERILATOR} --binary -Wno-UNOPTFLAT -Wno-UNSIGNED --trace -trace-max-array 128 --trace-structs -f $BASEDIR/sim/files.f --top-module soc 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
else
  ${VERILATOR} --binary -Wno-UNOPTFLAT -Wno-UNSIGNED -f $BASEDIR/sim/files.f --top-module soc 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
fi
if [[ -n "${benchmark[$PROGRAM]}" ]]
then
  cp $BASEDIR/build/$PROGRAM/dat/$PROGRAM.dat bram.dat
  cp $BASEDIR/build/$PROGRAM/elf/$PROGRAM.host host.dat
  obj_dir/Vsoc
elif [[ -n "${verification[$PROGRAM]}" ]]
then
  for filename in $BASEDIR/build/$PROGRAM/dat/*.dat; do
    filename=${filename##*/}
    filename=${filename%.dat}
    echo "$filename"
    cp $BASEDIR/build/$PROGRAM/dat/$filename.dat bram.dat
    cp $BASEDIR/build/$PROGRAM/elf/$filename.host host.dat
    obj_dir/Vsoc
  done
else
  subpath=${PROGRAM%/dat*}
  filename=${PROGRAM##*/}
  filename=${filename%.dat}
  cp $BASEDIR/$subpath/dat/$filename.dat bram.dat
  cp $BASEDIR/$subpath/elf/$filename.host host.dat
  if [ -e $BASEDIR/$subpath/elf/$filename.begin_signature ]
  then
    cp $BASEDIR/$subpath/elf/$filename.begin_signature begin_signature.dat
  fi
  if [ -e $BASEDIR/$subpath/elf/$filename.end_signature ]
  then
    cp $BASEDIR/$subpath/elf/$filename.end_signature end_signature.dat
  fi
  if [ -e $BASEDIR/$subpath/elf/$filename.reference_output ]
  then
    cp $BASEDIR/$subpath/elf/$filename.reference_output reference.dat
  fi
  obj_dir/Vsoc
  if [ -f "reference.dat" ]
  then
    if [ "$(diff --color reference.dat signature.dat)" != "" ]
    then
      echo "${red}RESULTS INCORRECT${reset}"
    else
      echo "${green}RESULTS CORRECT${reset}"
    fi
  fi
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
