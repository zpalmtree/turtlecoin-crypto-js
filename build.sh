#!/bin/sh

# Set up emscripten

if [[ -z "${EMSDK}" ]]; then
  echo "Installing emscripten..."
  echo ""
  git clone https://github.com/juj/emsdk.git
  cd emsdk && git pull
  ./emsdk install latest && ./emsdk activate latest
  source ./emsdk_env.sh
  cd ..
fi

echo ""
echo "Creating build folder..."
mkdir -p build && cd build

# Compile our C dependencies
echo ""
echo -n "Transpiling C dependencies to bytecode... "
emcc ../src/*.c -o c.bc
echo " Done"

# Compile our C++ dependencies
echo ""
echo -n "Transpiling C++ dependencies to bytecode... "
emcc -std=c++17 ../src/crypto.cpp ../src/StringTools.cpp -o cpp.bc
echo " Done"

# Compile the actual file
echo ""
echo -n "Transpiling Project from C++ to Javascript... "
emcc -s WASM=0 --bind -std=c++17 c.bc cpp.bc ../src/turtlecoin-crypto.cpp -o turtlecoin-crypto.js
echo " Done"

cd ..
