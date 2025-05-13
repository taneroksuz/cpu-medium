#!/bin/bash
set -e

sudo apt-get -y install jq curl wget tk gcc-11 g++-11 build-essential cmake tclsh \
                        ant default-jre swig google-perftools libgoogle-perftools-dev \
                        python3 python3-dev python3-pip uuid uuid-dev tcl-dev flex \
                        libfl-dev git pkg-config libreadline-dev bison libffi-dev wget \
                        python3-orderedmultidict


if [ -d "$BASEDIR/tools/synlig" ]; then
  rm -rf $BASEDIR/tools/synlig
fi

git clone https://github.com/chipsalliance/synlig.git

cd synlig

git submodule sync
git submodule update --init --recursive third_party/{surelog,yosys}
make build -j$(nproc)

sudo make install