#!/bin/bash
set -e

PREFIX=/opt/csmith

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

sudo apt-get -y install build-essential g++ cmake m4

if [ -d "csmith" ]; then
  rm -rf csmith
fi

git clone https://github.com/csmith-project/csmith.git

cd csmith

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX

make -j$(nproc)
make install
