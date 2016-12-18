git submodule update --init --recursive
cd tapir
mkdir -p build
cd build
cmake ..
make -j12
