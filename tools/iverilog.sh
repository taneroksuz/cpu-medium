#!/bin/bash
set -e

PREFIX=/opt/iverilog

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

sudo apt-get -y install git build-essential make g++ autoconf

if [ -d "iverilog" ]; then
  rm -rf iverilog
fi

git clone https://github.com/steveicarus/iverilog.git

cd iverilog

git checkout --track -b v12-branch origin/v12-branch

git pull
sh autoconf.sh

./configure --prefix=$PREFIX

make -j$(nproc)
make install
