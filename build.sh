#!/usr/bin/env bash

# Top-level source directory
LLVM_SRC=$PWD/tapir
# Build directory
LLVM_BUILD=$LLVM_SRC/build
INSTALL=$PWD/install

# Intel Cilk Plus RTS source and build directories
CILKRTS_SRC=$PWD/cilkrts
CILKRTS_BUILD=$CILKRTS_SRC/build

# Die if anything produces an error
set -e

if [ -z $1 ]; then
    MODE=-DCMAKE_BUILD_TYPE=Release
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
        echo Or no argument for release.
        exit
        ;;
    esac
fi

if [ -z $TAPIR_NOUPDATE ]; then
    # Update the Tapir/LLVM and PClang repositories
    echo "$0: git submodule update --init"
    git submodule update --init
fi

# Create or recreate the Tapir/LLVM build directory
echo "$0: rm -rf $LLVM_BUILD"
rm -rf $LLVM_BUILD
echo "$0: mkdir -p $LLVM_BUILD"
mkdir -p $LLVM_BUILD

# Enter the build directory
echo "$0: pushd $LLVM_BUILD"
pushd $LLVM_BUILD

# Configure the build
echo "$0: cmake $MODE -DLLVM_TARGETS_TO_BUILD=host -DCMAKE_INSTALL_PREFIX=$LLVM_SRC/../install $LLVM_SRC"
cmake $MODE -DLLVM_TARGETS_TO_BUILD=host -DLLVM_BINUTILS_INCDIR=/usr/include -DCMAKE_INSTALL_PREFIX=$INSTALL $LLVM_SRC

# Get hardware thread count
HThreadCount=$(lscpu -p | egrep -v '^#' | wc -l)

# Build the compiler
echo "$0: cmake --build . -- -j$HThreadCount"
cmake --build . -- -j$HThreadCount

# Install the compiler
echo "$0: cmake --build . --target install"
cmake --build . --target install
popd

# Create or recreate the Intel Cilk Plus RTS build directory
echo "$0: rm -rf $CILKRTS_BUILD"
rm -rf $CILKRTS_BUILD
echo "$0: mkdir -p $CILKRTS_BUILD"
mkdir -p $CILKRTS_BUILD

# Enter that build directory
echo "$0: pushd $CILKRTS_BUILD"
pushd $CILKRTS_BUILD

# Configure the build to use Tapir/LLVM
echo "$0: cmake $MODE -DCMAKE_C_COMPILER=$INSTALL/bin/clang -DCMAKE_CXX_COMPILER=$INSTALL/bin/clang++ -DCMAKE_INSTALL_PREFIX=$INSTALL $CILKRTS_SRC"
cmake $MODE -DCMAKE_C_COMPILER=$INSTALL/bin/clang -DCMAKE_CXX_COMPILER=$INSTALL/bin/clang++ -DCMAKE_INSTALL_PREFIX=$INSTALL $CILKRTS_SRC

# Build and install the Intel Cilk Plus RTS
echo "$0: cmake --build . --target install"
cmake --build . --target install
popd

echo "Installation successful"

if [[ $* == *--deb* ]]
then
    echo "Building Debian file"
    ./deb.sh
fi
