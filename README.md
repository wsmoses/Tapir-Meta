# Tapir-Meta/Dandelion

This is the top-level meta-repository for downloading and building the Tapir/LLVM compiler and PClang front end. This version is modified version of official branch. Dandelion works at the bitcode level of Tapir before lowring LLVM IR to Cilk. Therefore, in this version we have an option to highjack the LLVM bitcode before lowering phase to Cilk.

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

## Programming Cilk program
The Cilk programming language provides a simple extension to the C and C++ languages that allow programmers to expose logically parallel tasks.
Cilk extends C and C++ with three keywords: `cilk_spawn`, `cilk_sync`, and `cilk_for`. This page describes the Cilk language extension.

### Spawn and sync
Let us first examine the task-parallel keywords `cilk_spawn` and `cilk_sync`. Consider the following example code for a fib routine, which uses these keywords to parallelize the computation of the nth Fibonacci number.

```C++
int64_t fib(int64_t n) {
  if (n < 2) return n;
  int x, y;
  x = cilk_spawn fib(n - 1);
  y = fib(n - 2);
  cilk_sync;
  return x + y;
}
```

In the simplest usage of cilk_spawn, parallel work is created when cilk_spawn precedes the invocation of a function, thereby causing the function to be spawned. The semantics of spawning differ from a C/C++ function or method call only in that the parent continuation — the code immediately following the spawn — is allowed to execute in parallel with the child, instead of waiting for the child to complete as is done in C/C++. In the example fib function, the cilk_spawn spawns the recursive invocation of fib(n-1), allowing it to execute in parallel with its continuation, which calls fib(n-2).

A function cannot safely use the values returned by its spawned children until it executes a cilk_sync statement, which suspends the function until all of its spawned children return. The cilk_sync is a local "barrier," not a global one as, for example, is used in message-passing programming. In fib, the cilk_sync prevents the execution of fib from continuing past the cilk_sync until the spawned invocation of fib(n-1) has returned.

Together, a programmer can use the cilk_spawn and cilk_sync keywords to expose logical fork-join parallelism within a program. The cilk_spawn keyword creates a parallel task, which is not required to execute in parallel, but simply allowed to do so. The fib example also demonstrates that the cilk_spawn and cilk_sync keywords are composable: a spawned subcomputation can itself spawn and sync child subcomputations. The scheduler in the runtime system takes the responsibility of scheduling parallel tasks on individual processor cores of a multicore computer and synchronizing their returns.

### Parallel loops
A for loop can be parallelized by replacing the for with the cilk_for keyword, as demonstrated by the following code to compute y=ax+y from two given vectors x and y and a given scalar value a:

```C++
void daxpy(int n, double a, double *x, double *y) {
  cilk_for (int i = 0; i < n; ++i) {
    y[i] = a * x[i] + y[i];
  }
}
```
The cilk_for parallel-loop construct indicates that all iterations of the loop are allowed to execute in parallel. At runtime, these iterations can execute in any order, at the discretion of the runtime scheduler.

The cilk_for construct is composable, allowing for simple parallelization of nested loops. The mm routine in the following code example demonstrates how nested cilk_for loops can be used to parallelize a simple code to compute the matrix product C=A⋅B where A, B, and C are n×n matrices in row-major order:

```c++
void mm(const double *restrict A,
        const double *restrict B,
        double *restrict C,
        int64_t n) {
  cilk_for (int64_t i = 0; i < n; ++i) {
    cilk_for (int64_t j = 0; j < n; ++j) {
      for (int64_t k = 0; k < n; ++k) {
        C[i*n + j] += A[i*n + k] * B[k*n + j];
      }
    }
  }
}
```


## Compiling Cilk program

Compiling a Cilk program is similar to compiling an ordinary C or C++ program. To compile a Cilk program using Tapir/LLVM, add the `-fcilkplus` flag to the clang or clang++ command you would use to compile and link an ordinary serial program. When run, the resulting executable will use the Cilk runtime system to execute in parallel on whatever parallel processors are available on the machine.

You can find cilkrts.so file under cilkrts/build or the path should in your environment.

## Bitcode extraction

Modified version of Tapir allows user to store LLVM bitcode before lowering phase to Cilk.
To extract bitcode, you need to set the follwoing environemnt variable:

```shell
    export DANDELION_EXTRACT=ON
```

And then compile the program with clang. In the same folder, a new bc file would be generated with prefix of: `.dandelion.bc`. This bc file contains detach, attach and sync instructions from Tapir.
