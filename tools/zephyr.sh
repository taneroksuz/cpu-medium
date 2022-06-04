#!/bin/bash

export PATH=$HOME/.local/bin:$PATH

if [ -d "$HOME/zephyrproject" ]; then
    rm -rf $HOME/zephyrproject
fi
if [ -d "$HOME/zephyr-sdk-0.11.3" ]; then
    rm -rf $HOME/zephyr-sdk-0.11.3
fi

if [ -f "zephyr-sdk-0.11.3-setup.run" ]; then
    rm zephyr-sdk-0.11.3-setup.run
fi

pip3 uninstall -y cmake
pip3 uninstall -y west

wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.11.3/zephyr-sdk-0.11.3-setup.run
chmod +x zephyr-sdk-0.11.3-setup.run
./zephyr-sdk-0.11.3-setup.run -- -d $HOME/zephyr-sdk-0.11.3

pip3 install --user cmake
pip3 install --user west
west init $HOME/zephyrproject
cd $HOME/zephyrproject
west update

pip3 uninstall -y -r zephyr/scripts/requirements.txt
pip3 install --user -r zephyr/scripts/requirements.txt
