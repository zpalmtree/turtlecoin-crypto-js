#!/bin/sh

# Set up emscripten

if [[ -z "${EMSDK}" ]]; then
  echo "Installing emscripten..."
  echo ""
  if [[ ! -e ./emsdk ]]; then
    git clone https://github.com/juj/emsdk.git
  fi
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

emcc -O3 \          `# Aggressive optimization` \
    ../src/*.c \    `# Input files` \
    -o c.bc         `# Output file`

echo " Done"

# Compile our C++ dependencies
echo ""
echo -n "Transpiling C++ dependencies to bytecode... "

emcc -O3 \                                      `# Aggressive optimization` \
     -std=c++17 \                               `# Use C++17 compilation standard` \
     ../src/crypto.cpp ../src/StringTools.cpp \ `# Input files` \
     -o cpp.bc                                  `# Output file`

echo " Done"

# Compile the actual file
echo ""
echo -n "Transpiling Project from C++ to Javascript... "

# Standard build
emcc -g1                                      `# Don't completely make the JS unreadable. Makes it easier to patch for react native` \
     -O3                                      `# Aggressive optimization` \
     -s WASM=0                                `# Don't use wasm, use asm.js instead` \
     -s POLYFILL_OLD_MATH_FUNCTIONS=1         `# Provide polyfills for some math functions, needed for react-native` \
     --bind                                   `# Compiles the source code using the Embind bindings to connect C/C++ (yeah idk what that means either)` \
     -std=c++17                               `# Use C++17 compilation standard` \
     --memory-init-file 0                     `# Don't add a separate memory initialization file (Doesn't work with react native)` \
     -o "turtlecoin-crypto.js"                `# Output to "turtlecoin-crypto.js"` \
     c.bc cpp.bc ../src/turtlecoin-crypto.cpp `# Input files`

# Node only build
emcc -g1                                      `# Don't completely make the JS unreadable. Makes it easier to patch for react native` \
     -O3                                      `# Aggressive optimization` \
     -s WASM=0                                `# Don't use wasm, use asm.js instead` \
     -s POLYFILL_OLD_MATH_FUNCTIONS=1         `# Provide polyfills for some math functions, needed for react-native` \
     --bind                                   `# Compiles the source code using the Embind bindings to connect C/C++ (yeah idk what that means either)` \
     -std=c++17                               `# Use C++17 compilation standard` \
     -s ENVIRONMENT=node                      `# Compile just for node` \
     --memory-init-file 0                     `# Don't add a separate memory initialization file (Doesn't work with react native)` \
     -o "turtlecoin-crypto-node.js"           `# Output to "turtlecoin-crypto-node.js"` \
     c.bc cpp.bc ../src/turtlecoin-crypto.cpp `# Input files`

# Web only build
emcc -g1                                      `# Don't completely make the JS unreadable. Makes it easier to patch for react native` \
     -O3                                      `# Aggressive optimization` \
     -s WASM=0                                `# Don't use wasm, use asm.js instead` \
     -s POLYFILL_OLD_MATH_FUNCTIONS=1         `# Provide polyfills for some math functions, needed for react-native` \
     --bind                                   `# Compiles the source code using the Embind bindings to connect C/C++ (yeah idk what that means either)` \
     -std=c++17                               `# Use C++17 compilation standard` \
     -s ENVIRONMENT=web                       `# Compile just for the web` \
     --memory-init-file 0                     `# Don't add a separate memory initialization file (Doesn't work with react native)` \
     -o "turtlecoin-crypto-web.js"            `# Output to "turtlecoin-crypto-web.js"` \
     c.bc cpp.bc ../src/turtlecoin-crypto.cpp `# Input files`

# Worker only build
emcc -g1                                      `# Don't completely make the JS unreadable. Makes it easier to patch for react native` \
     -O3                                      `# Aggressive optimization` \
     -s WASM=0                                `# Don't use wasm, use asm.js instead` \
     -s POLYFILL_OLD_MATH_FUNCTIONS=1         `# Provide polyfills for some math functions, needed for react-native` \
     --bind                                   `# Compiles the source code using the Embind bindings to connect C/C++ (yeah idk what that means either)` \
     -std=c++17                               `# Use C++17 compilation standard` \
     -s ENVIRONMENT=worker                    `# Compile just for a worker` \
     --memory-init-file 0                     `# Don't add a separate memory initialization file (Doesn't work with react native)` \
     -o "turtlecoin-crypto-worker.js"         `# Output to "turtlecoin-crypto-worker.js"` \
     c.bc cpp.bc ../src/turtlecoin-crypto.cpp `# Input files`

# Shell only build
emcc -g1                                      `# Don't completely make the JS unreadable. Makes it easier to patch for react native` \
     -O3                                      `# Aggressive optimization` \
     -s WASM=0                                `# Don't use wasm, use asm.js instead` \
     -s POLYFILL_OLD_MATH_FUNCTIONS=1         `# Provide polyfills for some math functions, needed for react-native` \
     --bind                                   `# Compiles the source code using the Embind bindings to connect C/C++ (yeah idk what that means either)` \
     -std=c++17                               `# Use C++17 compilation standard` \
     -s ENVIRONMENT=shell                     `# Compile just for a shell` \
     --memory-init-file 0                     `# Don't add a separate memory initialization file (Doesn't work with react native)` \
     -o "turtlecoin-crypto-shell.js"          `# Output to "turtlecoin-crypto-shell.js"` \
     c.bc cpp.bc ../src/turtlecoin-crypto.cpp `# Input files`

echo " Done"

cd ..
