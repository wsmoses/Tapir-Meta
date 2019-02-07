# Tapir-Meta

This is the top-level meta-repository for downloading and building the Tapir/LLVM compiler and PClang front end.

## Building Tapir/LLVM and PClang

To build Tapir/LLVM and PClang (debug-mode), execute the following commands:

    git clone --recursive git@csil-git1.cs.surrey.sfu.ca:Dandelion/Tapir-Meta.git
    cd Tapir-Meta/
    ./build.sh
    source ./setup-env.sh

This produces **very** large, slow binaries.

Alternatively, you can get the smaller, faster release binaries using:

    ./build.sh release

Or, you can get something in between (optimized, but with debug information):

    ./build.sh debinfo

Building Tapir/LLVM and PClang can take a long time to complete, depending on the computational resources  of machine you are building on.

## Extracting bitcode
For extracting bitcode set the follwoing environemnt variable:

```shell
export DANDELION_EXTRACT=ON
```
