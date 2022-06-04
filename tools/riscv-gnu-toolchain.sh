riscv-isa-sim#!/bin/bash

RISCV_PATH=/opt/riscv
FLAG1="rv32i-ilp32--;rv32im-ilp32--;rv32imc-ilp32--;"
FLAG2="rv64i-lp64--;rv64im-lp64--;rv64imc-lp64--;"
FLAG3="rv64imfd-lp64d--;rv64imfdc-lp64d--"
FLAG="$FLAG1$FLAG2$FLAG3"


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

# RISCV LLVM

git clone https://github.com/llvm/llvm-project.git riscv-llvm

cd riscv-llvm

ln -s ../../clang llvm/tools || true

mkdir build
cd build

cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
  -DCMAKE_INSTALL_PREFIX=$RISCV_PATH \
  -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
  -DDEFAULT_SYSROOT="$RISCV_PATH/riscv64-unknown-elf" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
  -DLLVM_TARGETS_TO_BUILD="RISCV" \
  ../llvm

cmake --build . --target install

# RISCV ISA SIM

git clone --recursive https://github.com/riscv/riscv-isa-sim.git

cd riscv-isa-sim

mkdir build
cd build

../configure --prefix=$RISCV_PATH

make -j$(nproc)

make install

# ELF2HEX

git clone --recursive https://github.com/sifive/elf2hex.git

cd elf2hex

autoreconf -i

mkdir build
cd build

../configure --prefix=$RISCV_PATH

make -j$(nproc)

make install
