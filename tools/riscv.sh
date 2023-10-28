#!/bin/bash
set -e

PREFIX=/opt/rv32imfcb

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

if [ -d "riscv-gnu-toolchain" ]; then
  rm -rf riscv-gnu-toolchain/
fi

mkdir riscv-gnu-toolchain

sudo apt-get -y install autoconf automake autotools-dev curl \
                        python3 python3-pip libmpc-dev libmpfr-dev \
                        libgmp-dev gawk build-essential bison flex \
                        texinfo gperf libtool patchutils bc zlib1g-dev \
                        libexpat-dev ninja-build git cmake libglib2.0-dev

git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain

mkdir build
cd build

../configure --prefix=$PREFIX --disable-linux --with-arch=rv32imfc_zba_zbb_zbc_zbs \
             --with-abi=ilp32

make -j$(nproc) newlib
