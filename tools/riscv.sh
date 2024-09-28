#!/bin/bash
set -e

RISCV=/opt/rv32imfdcb/
ARCH=rv32imfdc_zba_zbb_zbc_zbs_zicsr_zifencei
ABI=ilp32d

if [ -d "$RISCV" ]; then
  sudo rm -rf $RISCV
fi

sudo mkdir -p $RISCV
sudo chown -R $USER:$USER $RISCV

sudo apt-get -y install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev \
                        libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
                        libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake \
                        libglib2.0-dev libslirp-dev

if [ -d "$BASEDIR/tools/riscv-gnu-toolchain" ]; then
  rm -rf $BASEDIR/tools/riscv-gnu-toolchain
fi

git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git $BASEDIR/tools/riscv-gnu-toolchain

mkdir -p $BASEDIR/tools/riscv-gnu-toolchain/build
cd $BASEDIR/tools/riscv-gnu-toolchain/build

../configure --enable-llvm --disable-linux --with-arch=$ARCH --with-abi=$ABI --prefix=$RISCV

make -j$(nproc)
make install