#!/bin/bash
set -e

CSMITH_PATH=/opt/csmith

if [ -d "csmith-2.3.0" ]; then
  rm -rf csmith-2.3.0
fi
if [ -f "csmith-2.3.0.tar.gz" ]; then
  rm  csmith-2.3.0.tar.gz
fi

wget https://embed.cs.utah.edu/csmith/csmith-2.3.0.tar.gz
tar xf csmith-2.3.0.tar.gz

cd csmith-2.3.0

sudo apt-get install build-essential m4

./configure --prefix=$CSMITH_PATH

make -j$(nproc)
sudo make install
