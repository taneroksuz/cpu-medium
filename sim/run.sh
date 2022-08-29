#!/bin/bash
set -e

DIR=${1}

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

rm -rf $DIR/sim/work/*

VERILATOR=${2}
SYSTEMC=${3}

export SYSTEMC_LIBDIR=$SYSTEMC/lib-linux64/
export SYSTEMC_INCLUDE=$SYSTEMC/include/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC/lib-linux64/

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

if [[ "$5" = [0-9]* ]];
then
  CYCLES="$5"
else
  CYCLES=10000000000
fi

cd ${DIR}/sim/work

start=`date +%s`
if [ "$6" = 'on' ]
then
	${VERILATOR} --sc -Wno-UNOPTFLAT -Wno-UNSIGNED --trace -trace-max-array 128 --trace-structs -f ${DIR}/sim/files.f --top-module soc --exe ${DIR}/verilog/tb/soc.cpp
	make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
  if [ "$4" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat bram.dat
    cp $DIR/build/dhrystone/elf/dhrystone.host host.dat
  	obj_dir/Vsoc $CYCLES dhrystone 2> /dev/null
  elif [ "$4" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat bram.dat
    cp $DIR/build/coremark/elf/coremark.host host.dat
  	obj_dir/Vsoc $CYCLES coremark 2> /dev/null
  elif [ "$4" = 'aapg' ]
  then
    cp $DIR/build/aapg/dat/aapg.dat bram.dat
    cp $DIR/build/aapg/elf/aapg.host host.dat
  	obj_dir/Vsoc $CYCLES aapg 2> /dev/null
  elif [ "$4" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat bram.dat
    cp $DIR/build/csmith/elf/csmith.host host.dat
  	obj_dir/Vsoc $CYCLES csmith 2> /dev/null
  elif [ "$4" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat bram.dat
    cp $DIR/build/torture/elf/torture.host host.dat
  	obj_dir/Vsoc $CYCLES torture 2> /dev/null
  elif [ "$4" = 'uart' ]
  then
    cp $DIR/build/uart/dat/uart.dat bram.dat
    cp $DIR/build/uart/elf/uart.host host.dat
  	obj_dir/Vsoc $CYCLES uart 2> /dev/null
  elif [ "$4" = 'timer' ]
  then
    cp $DIR/build/timer/dat/timer.dat bram.dat
    cp $DIR/build/timer/elf/timer.host host.dat
  	obj_dir/Vsoc $CYCLES timer 2> /dev/null
  elif [ "$4" = 'sram' ]
  then
    cp $DIR/build/sram/dat/sram.dat bram.dat
    cp $DIR/build/sram/elf/sram.host host.dat
  	obj_dir/Vsoc $CYCLES sram 2> /dev/null
  elif [ "$4" = 'compliance' ]
  then
    for filename in $DIR/build/compliance/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/compliance/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    done
  elif [ "$4" = 'ovp' ]
  then
    for filename in $DIR/build/ovp/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/ovp/elf/${filename}.host host.dat
      cp $DIR/build/ovp/elf/${filename}.begin_signature begin_signature.dat
      cp $DIR/build/ovp/elf/${filename}.end_signature end_signature.dat
      cp $DIR/build/ovp/ref/${filename}.reference_output reference.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    done
  elif [ "$4" = 'isa' ]
  then
    for filename in $DIR/build/isa/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/isa/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES ${filename} 2> /dev/null
    done
  else
    cp $DIR/$4 bram.dat
    filename="$4"
    dirname="$4"
    filename=${filename##*/}
    filename=${filename%.dat}
    subpath=${dirname%/dat*}
    cp $DIR/${subpath}/elf/${filename}.host host.dat
    if [ -e $DIR/${subpath}/elf/${filename}.begin_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.begin_signature begin_signature.dat
    fi
    if [ -e $DIR/${subpath}/elf/${filename}.end_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.end_signature end_signature.dat
    fi
    if [ -e $DIR/${subpath}/ref/${filename}.reference_output ]
    then
      cp $DIR/${subpath}/ref/${filename}.reference_output reference.dat
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
	${VERILATOR} --sc -Wno-UNOPTFLAT -Wno-UNSIGNED -f ${DIR}/sim/files.f --top-module soc --exe ${DIR}/verilog/tb/soc.cpp
	make -s -j -C obj_dir/ -f Vsoc.mk Vsoc
  if [ "$4" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat bram.dat
    cp $DIR/build/dhrystone/elf/dhrystone.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat bram.dat
    cp $DIR/build/coremark/elf/coremark.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'aapg' ]
  then
    cp $DIR/build/aapg/dat/aapg.dat bram.dat
    cp $DIR/build/aapg/elf/aapg.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat bram.dat
    cp $DIR/build/csmith/elf/csmith.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat bram.dat
    cp $DIR/build/torture/elf/torture.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'uart' ]
  then
    cp $DIR/build/uart/dat/uart.dat bram.dat
    cp $DIR/build/uart/elf/uart.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'timer' ]
  then
    cp $DIR/build/timer/dat/timer.dat bram.dat
    cp $DIR/build/timer/elf/timer.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'sram' ]
  then
    cp $DIR/build/sram/dat/sram.dat bram.dat
    cp $DIR/build/sram/elf/sram.host host.dat
  	obj_dir/Vsoc $CYCLES 2> /dev/null
  elif [ "$4" = 'compliance' ]
  then
    for filename in $DIR/build/compliance/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/compliance/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
    done
  elif [ "$4" = 'ovp' ]
  then
    for filename in $DIR/build/ovp/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/ovp/elf/${filename}.host host.dat
      cp $DIR/build/ovp/elf/${filename}.begin_signature begin_signature.dat
      cp $DIR/build/ovp/elf/${filename}.end_signature end_signature.dat
      cp $DIR/build/ovp/ref/${filename}.reference_output reference.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
      if [ "$(diff --color reference.dat signature.dat)" != "" ]
      then
        echo "${red}RESULTS NOT OK${reset}"
      else
        echo "${green}RESULTS OK${reset}"
      fi
    done
  elif [ "$4" = 'isa' ]
  then
    for filename in $DIR/build/isa/dat/*.dat; do
      cp $filename bram.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      cp $DIR/build/isa/elf/${filename}.host host.dat
      echo "${filename}"
    	obj_dir/Vsoc $CYCLES 2> /dev/null
    done
  else
    cp $DIR/$4 bram.dat
    filename="$4"
    dirname="$4"
    filename=${filename##*/}
    filename=${filename%.dat}
    subpath=${dirname%/dat*}
    cp $DIR/${subpath}/elf/${filename}.host host.dat
    if [ -e $DIR/${subpath}/elf/${filename}.begin_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.begin_signature begin_signature.dat
    fi
    if [ -e $DIR/${subpath}/elf/${filename}.end_signature ]
    then
      cp $DIR/${subpath}/elf/${filename}.end_signature end_signature.dat
    fi
    if [ -e $DIR/${subpath}/ref/${filename}.reference_output ]
    then
      cp $DIR/${subpath}/ref/${filename}.reference_output reference.dat
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
