# Tapir-Meta

This is the top-level meta-repository for downloading and building the Tapir/LLVM compiler and PClang front end.

## Building Tapir/LLVM and PClang

To build Tapir/LLVM and PClang, execute the following commands:

   git clone --recursive https://github.com/wsmoses/Tapir-Meta.git
   cd Tapir-Meta
   ./build.sh
   source ./setup-env.sh

This can take a long time to complete, depending on the type of machine you are building on.