#!/bin/bash

if [ ! -d "sbt" ]; then
  wget https://piccolo.link/sbt-0.13.18.tgz
  tar xf sbt-0.13.18.tgz
fi

cd sbt

sudo cp -rf bin /usr/local/
sudo cp -rf conf /usr/local/
sudo cp -rf lib /usr/local/

cd -

sudo apt-get install openjdk-8-jdk

if [ ! -d "riscv-torture" ]; then
  git clone --recursive https://github.com/ucb-bar/riscv-torture.git
fi

cd riscv-torture

git checkout 59b0f0f

patch -p1 < ../riscv-torture.diff

sbt generator/run
