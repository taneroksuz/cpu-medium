#!/bin/bash
set -e

PREFIX=/opt/riscv-llvm

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

if [ -d "riscv-llvm" ]; then
  rm -rf riscv-llvm/
fi

mkdir riscv-llvm
cd riscv-llvm

sudo apt-get -y install \
  binutils build-essential libtool texinfo \
  gzip zip unzip patchutils curl git \
  make cmake ninja-build automake bison flex gperf \
  grep sed gawk python3 bc \
  zlib1g-dev libexpat1-dev libmpc-dev \
  libglib2.0-dev libfdt-dev libpixman-1-dev

git clone --depth 1 https://github.com/llvm/llvm-project.git

cd llvm-project

mkdir build

cmake -G Ninja -B build -S llvm \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_SYSTEM_NAME="Linux" \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DLLVM_HOST_TRIPLE="riscv32-unknown-elf" \
  -DLLVM_TARGETS_TO_BUILD="RISCV"

ninja -C build
ninja -C build install
