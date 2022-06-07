#!/bin/bash

RISCV_PATH=/opt/riscv
FLAG1="rv32i-ilp32--;rv32im-ilp32--;rv32imc-ilp32--;"
FLAG2="rv32imfc-ilp32--;rv32imfdc-ilp32--"
FLAG="$FLAG1$FLAG2"


if [ -d "$RISCV_PATH" ]
then
  sudo rm -rf $RISCV_PATH
fi
sudo mkdir $RISCV_PATH
sudo chown -R $USER $RISCV_PATH/

sudo apt-get -y install \
  binutils build-essential libtool texinfo \
  gzip zip unzip patchutils curl git \
  make cmake ninja-build automake bison flex gperf \
  grep sed gawk python bc \
  zlib1g-dev libexpat1-dev libmpc-dev \
  libglib2.0-dev libfdt-dev libpixman-1-dev

# RISCV GNU TOOLCHAIN

if [ -d "riscv-gnu-toolchain" ]; then
  rm -rf riscv-gnu-toolchain/
fi

git clone --recursive https://github.com/riscv/riscv-gnu-toolchain

cd riscv-gnu-toolchain

mkdir build
cd build

../configure --prefix=$RISCV_PATH --with-multilib-generator=$FLAG
make -j$(nproc)
