#!/bin/bash
set -e

RISCV_PATH=/opt/rv32imfcb

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

git clone --depth 1 https://github.com/gcc-mirror/gcc.git
git clone --depth 1 https://github.com/bminor/binutils-gdb.git
git clone --depth 1 https://github.com/bminor/newlib.git

mkdir combined
cd combined

ln --force -s ../newlib/* .
ln --force -s ../binutils-gdb/* .
ln --force -s ../gcc/* .

mkdir build
cd build

../configure --target=riscv32-unknown-elf --enable-languages=c \
  --disable-shared --disable-threads --disable-multilib --disable-gdb \
  --disable-libssp --with-newlib \
  --with-arch=rv32imfc_zba_zbb_zbc_zbs --with-abi=ilp32f --prefix=$RISCV_PATH

make -j$(nproc)
make install
