#!/bin/bash
set -e

INSTALL_PATH=/opt/riscv-dv

if [ -d "$INSTALL_PATH" ]
then
  sudo rm -rf $INSTALL_PATH
fi
sudo mkdir $INSTALL_PATH
sudo chown -R $USER $INSTALL_PATH/

if [ -d "riscv-dv" ]; then
  rm -rf riscv-dv
fi

git clone https://github.com/google/riscv-dv.git $INSTALL_PATH

cd $INSTALL_PATH

pip3 install --user -r requirements.txt

pip3 install --user -e .

if ! grep -q  "export PATH=\$HOME/.local/bin/:\$PATH" "$HOME/.bashrc"; then
  echo "export PATH=\$HOME/.local/bin/:\$PATH" >> $HOME/.bashrc
fi

