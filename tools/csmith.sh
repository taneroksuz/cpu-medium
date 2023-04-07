#!/bin/bash
set -e

PREFIX=/opt/csmith

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

sudo apt-get -y install build-essential m4

if [ -d "csmith-2.3.0" ]; then
  rm -rf csmith-2.3.0
fi
if [ -f "csmith-2.3.0.tar.gz" ]; then
  rm  csmith-2.3.0.tar.gz
fi

wget https://embed.cs.utah.edu/csmith/csmith-2.3.0.tar.gz
tar xf csmith-2.3.0.tar.gz

cd csmith-2.3.0

./configure --prefix=$PREFIX

make -j$(nproc)
make install
