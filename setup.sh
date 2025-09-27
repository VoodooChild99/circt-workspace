#!/bin/bash

sudo apt-get install git
git clone https://github.com/llvm/circt.git
cd circt || exit 1
git submodule init
git submodule update
cd ..
mkdir workspace
