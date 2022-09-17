#!/bin/bash
set -e

RISCV_PATH=/opt/riscv

if [ -d "$RISCV_PATH" ]
then
  sudo rm -rf $RISCV_PATH
fi
sudo mkdir $RISCV_PATH
sudo chown -R $USER $RISCV_PATH/

if [ -d "riscv-gcc" ]; then
  rm -rf riscv-gcc/
fi

mkdir riscv-gcc
cd riscv-gcc

sudo apt-get install git autoconf automake autotools-dev curl libmpc-dev \
  libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
  patchutils bc zlib1g-dev libexpat-dev texinfo python3 device-tree-compiler

wget https://github.com/gcc-mirror/gcc/archive/refs/tags/releases/gcc-12.2.0.tar.gz
wget https://github.com/bminor/binutils-gdb/archive/refs/tags/binutils-2_39.tar.gz
wget https://github.com/mirror/newlib-cygwin/archive/refs/tags/newlib-4.1.0.tar.gz

tar xfz gcc-12.2.0.tar.gz
tar xfz binutils-2_39.tar.gz
tar xfz newlib-4.1.0.tar.gz

mkdir combined
cd combined

ln --force -s ../newlib-cygwin-newlib-4.1.0/* .
ln --force -s ../binutils-gdb-binutils-2_39/* .
ln --force -s ../gcc-releases-gcc-12.2.0/* .

mkdir build
cd build

../configure --target=riscv32-unknown-elf --enable-languages=c \
  --disable-shared --disable-threads --disable-multilib --disable-gdb \
  --disable-libssp --with-newlib \
  --with-arch=rv32imc --with-abi=ilp32 --prefix=$RISCV_PATH

make -j$(nproc)
make install
