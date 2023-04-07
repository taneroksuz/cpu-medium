#!/bin/bash
set -e

PREFIX=/opt/riscv-dv

if [ -d "$PREFIX" ]
then
  sudo rm -rf $PREFIX
fi
sudo mkdir $PREFIX
sudo chown -R $USER:$USER $PREFIX/

sudo apt-get install -y python3-pip python3-setuptools

git clone https://github.com/google/riscv-dv.git $PREFIX

cd $PREFIX

pip3 install --user -r requirements.txt

pip3 install --user -e .

if [[ ":$PATH:" =~ *":$HOME/.local/bin:"* ]]; then
  echo "export PATH=\$HOME/.local/bin/:\$PATH" >> $HOME/.bashrc
fi

