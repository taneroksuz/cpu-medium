#!/bin/bash

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

git clone --depth=1 git://gcc.gnu.org/git/gcc.git gcc
git clone --depth=1 git://sourceware.org/git/binutils-gdb.git
git clone --depth=1 git://sourceware.org/git/newlib-cygwin.git

mkdir combined
cd combined

ln --force -s ../newlib-cygwin/* .
ln --force -s ../binutils-gdb/* .
ln --force -s ../gcc/* .

mkdir build
cd build

../configure --target=riscv32-unknown-elf --enable-languages=c \
  --disable-shared --disable-threads --disable-multilib --disable-gdb \
  --disable-libssp --with-newlib \
  --with-arch=rv32imc --with-abi=ilp32 --prefix=$RISCV_PATH

make -j$(nproc)
make install