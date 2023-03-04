#!/bin/bash
set -e

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

export SYSTEMC_LIBDIR=$SYSTEMC/lib-linux64/
export SYSTEMC_INCLUDE=$SYSTEMC/include/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC/lib-linux64/

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

cd $BASEDIR/sim/work

start=`date +%s`
if [ "$WAVE" = 'on' ]
then
	${VERILATOR} --sc -Wno-UNOPTFLAT -Wno-UNSIGNED --trace -trace-max-array 128 --trace-structs -f $BASEDIR/sim/files.f --top-module soc --exe $BASEDIR/verilog/tb/soc.cpp
	make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
  if [ "$PROGRAM" = 'dhrystone' ]
  then
    cp $BASEDIR/build/dhrystone/dat/dhrystone.dat bram.dat
    cp $BASEDIR/build/dhrystone/elf/dhrystone.host host.dat
  	obj_dir/Vsoc $CYCLES dhrystone 2> /dev/null
  elif [ "$PROGRAM" = 'whetstone' ]
  then
    cp $BASEDIR/build/whetstone/dat/whetstone.dat bram.dat
    cp $BASEDIR/build/whetstone/elf/whetstone.host host.dat
  	obj_dir/Vsoc $CYCLES whetstone 2> /dev/null
  elif [ "$PROGRAM" = 'coremark' ]
  then
    cp $BASEDIR/build/coremark/dat/coremark.dat bram.dat
    cp $BASEDIR/build/coremark/elf/coremark.host host.dat
  	obj_dir/Vsoc $CYCLES coremark 2> /dev/null
  elif [ "$PROGRAM" = 'aapg' ]
  then
    cp $BASEDIR/build/aapg/dat/aapg.dat bram.dat
    cp $BASEDIR/build/aapg/elf/aapg.host host.dat
  	obj_dir/Vsoc $CYCLES aapg 2> /dev/null
  elif [ "$PROGRAM" = 'riscv-dv' ]
  then
    cp $BASEDIR/build/riscv-dv/dat/riscv-dv.dat bram.dat
    cp $BASEDIR/build/riscv-dv/elf/riscv-dv.host host.dat
  	obj_dir/Vsoc $CYCLES riscv-dv 2> /dev/null
  elif [ "$PROGRAM" = 'csmith' ]
  then
    cp $BASEDIR/build/csmith/dat/csmith.dat bram.dat
    cp $BASEDIR/build/csmith/elf/csmith.host host.dat
  	obj_dir/Vsoc $CYCLES csmith 2> /dev/null
  elif [ "$PROGRAM" = 'torture' ]
  then
    cp $BASEDIR/build/torture/dat/torture.dat bram.dat
    cp $BASEDIR/build/torture/elf/torture.host host.dat
  	obj_dir/Vsoc $CYCLES torture 2> /dev/null
  elif [ "$PROGRAM" = 'bootloader' ]
  then
    cp $BASEDIR/build/bootloader/dat/bootloader.dat bram.dat
    cp $BASEDIR/build/bootloader/elf/bootloader.host host.dat
  	obj_dir/Vsoc $CYCLES bootloader 2> /dev/null
  elif [ "$PROGRAM" = 'timer' ]
  then
    cp $BASEDIR/build/timer/dat/timer.dat bram.dat
    cp $BASEDIR/build/timer/elf/timer.host host.dat
  	obj_dir/Vsoc $CYCLES timer 2> /dev/null
  elif [ "$PROGRAM" = 'sram' ]
  then
    cp $BASEDIR/build/sram/dat/sram.dat bram.dat
    cp $BASEDIR/build/sram/elf/sram.host host.dat
  	obj_dir/Vsoc $CYCLES sram 2> /dev/null
  elif [ "$PROGRAM" = 'compliance' ]
  then
    for filename in $BASEDIR/build/compliance/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $BASEDIR/build/compliance/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    done
  elif [ "$PROGRAM" = 'isa' ]
  then
    for filename in $BASEDIR/build/isa/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $BASEDIR/build/isa/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    done
  else
    cp $BASEDIR/$PROGRAM bram.dat
    filename="$PROGRAM"
    dirname="$PROGRAM"
    filename=${filename##*/}
    filename=${filename%.dat}
    subpath=${dirname%/dat*}
    cp $BASEDIR/${subpath}/elf/${filename}.host host.dat
    if [ -e $BASEDIR/${subpath}/elf/${filename}.begin_signature ]
    then
      cp $BASEDIR/${subpath}/elf/${filename}.begin_signature begin_signature.dat
    fi
    if [ -e $BASEDIR/${subpath}/elf/${filename}.end_signature ]
    then
      cp $BASEDIR/${subpath}/elf/${filename}.end_signature end_signature.dat
    fi
    if [ -e $BASEDIR/${subpath}/ref/${filename}.reference_output ]
    then
      cp $BASEDIR/${subpath}/ref/${filename}.reference_output reference.dat
    fi
    obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    if [ -f "reference.dat" ]
    then
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    fi
  fi
else
	${VERILATOR} --sc -Wno-UNOPTFLAT -Wno-UNSIGNED -f $BASEDIR/sim/files.f --top-module soc --exe $BASEDIR/verilog/tb/soc.cpp
	make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
  if [ "$PROGRAM" = 'dhrystone' ]
  then
    cp $BASEDIR/build/dhrystone/dat/dhrystone.dat bram.dat
    cp $BASEDIR/build/dhrystone/elf/dhrystone.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'whetstone' ]
  then
    cp $BASEDIR/build/whetstone/dat/whetstone.dat bram.dat
    cp $BASEDIR/build/whetstone/elf/whetstone.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'coremark' ]
  then
    cp $BASEDIR/build/coremark/dat/coremark.dat bram.dat
    cp $BASEDIR/build/coremark/elf/coremark.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'aapg' ]
  then
    cp $BASEDIR/build/aapg/dat/aapg.dat bram.dat
    cp $BASEDIR/build/aapg/elf/aapg.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'riscv-dv' ]
  then
    cp $BASEDIR/build/riscv-dv/dat/riscv-dv.dat bram.dat
    cp $BASEDIR/build/riscv-dv/elf/riscv-dv.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'csmith' ]
  then
    cp $BASEDIR/build/csmith/dat/csmith.dat bram.dat
    cp $BASEDIR/build/csmith/elf/csmith.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'torture' ]
  then
    cp $BASEDIR/build/torture/dat/torture.dat bram.dat
    cp $BASEDIR/build/torture/elf/torture.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'bootloader' ]
  then
    cp $BASEDIR/build/bootloader/dat/bootloader.dat bram.dat
    cp $BASEDIR/build/bootloader/elf/bootloader.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'timer' ]
  then
    cp $BASEDIR/build/timer/dat/timer.dat bram.dat
    cp $BASEDIR/build/timer/elf/timer.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'sram' ]
  then
    cp $BASEDIR/build/sram/dat/sram.dat bram.dat
    cp $BASEDIR/build/sram/elf/sram.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$PROGRAM" = 'compliance' ]
  then
    for filename in $BASEDIR/build/compliance/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $BASEDIR/build/compliance/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
    done
  elif [ "$PROGRAM" = 'isa' ]
  then
    for filename in $BASEDIR/build/isa/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $BASEDIR/build/isa/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
    done
  else
    cp $BASEDIR/$PROGRAM bram.dat
    filename="$PROGRAM"
    dirname="$PROGRAM"
    filename=${filename##*/}
    filename=${filename%.dat}
    subpath=${dirname%/dat*}
    cp $BASEDIR/${subpath}/elf/${filename}.host host.dat
    if [ -e $BASEDIR/${subpath}/elf/${filename}.begin_signature ]
    then
      cp $BASEDIR/${subpath}/elf/${filename}.begin_signature begin_signature.dat
    fi
    if [ -e $BASEDIR/${subpath}/elf/${filename}.end_signature ]
    then
      cp $BASEDIR/${subpath}/elf/${filename}.end_signature end_signature.dat
    fi
    if [ -e $BASEDIR/${subpath}/ref/${filename}.reference_output ]
    then
      cp $BASEDIR/${subpath}/ref/${filename}.reference_output reference.dat
    fi
    obj_dir/Vsoc $CYCLES 2> /dev/null
    if [ -f "reference.dat" ]
    then
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    fi
  fi
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
