#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
LLVM_BUILD=$DIR/tapir/build
export PATH=$LLVM_BUILD/bin:$PATH
