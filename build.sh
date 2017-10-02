#!/usr/bin/env bash

# Top-level source directory
LLVM_SRC=$PWD/tapir
# Build directory
LLVM_BUILD=$LLVM_SRC/build

# Die if anything produces an error
set -e

if [ -z $1 ]; then
    MODE=-DCMAKE_BUILD_TYPE=Debug
else
    case $1 in
    debug)
        MODE=-DCMAKE_BUILD_TYPE=Debug
        ;;
    release)
        MODE=-DCMAKE_BUILD_TYPE=Release
        ;;
    debinfo)
        MODE=-DCMAKE_BUILD_TYPE=RelWithDebInfo
        ;;
    minsize)
        MODE=-DCMAKE_BUILD_TYPE=MinSizeRel
        ;;
    *)
        echo Unknown build mode: $1
        echo 'Try: debug|release|debinfo|minsize'
        echo Or no argument for debug.
        exit
        ;;
    esac
fi

if [ -z $TAPIR_NOUPDATE ]; then
    # Update the Tapir/LLVM and PClang repositories
    echo "$0: git submodule update --init --recursive"
    git submodule update --init --recursive
fi

# Create the build directory if necessary
if [ ! -d $LLVM_BUILD ]; then
    echo "$0: mkdir $LLVM_BUILD"
    mkdir $LLVM_BUILD
fi

# Enter the build directory
echo "$0: cd $LLVM_BUILD"
cd $LLVM_BUILD

# Configure the build
echo "$0: cmake $MODE -DLLVM_TARGETS_TO_BUILD=host $LLVM_SRC"
cmake $MODE -DLLVM_TARGETS_TO_BUILD=host $LLVM_SRC

# Get hardware thread count
HThreadCount=$(lscpu -p | egrep -v '^#' | wc -l)

# Build the compiler
echo "$0: cmake --build . -- -j$HThreadCount"
cmake --build . -- -j$HThreadCount

echo "Installation successful"
cd ../..

if [[ $* == *--deb* ]]
then
    echo "Building Debian file"
    ./deb.sh
fi
