#!/bin/sh

# Set up emscripten

git clone https://github.com/juj/emsdk.git
cd emsdk && git pull
./emsdk install latest && ./emsdk activate latest
source ./emsdk_env.sh
cd ..

mkdir -p build && cd build

# Compile our C dependencies
emcc ../src/*.c -o c.bc

# Compile our C++ dependencies
emcc -std=c++17 ../src/crypto.cpp ../src/StringTools.cpp -o cpp.bc

# Compile the actual file
emcc -s WASM=0 --bind -std=c++17 c.bc cpp.bc ../src/turtlecoin-crypto.cpp -o turtlecoin-crypto.js
