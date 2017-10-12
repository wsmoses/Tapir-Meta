FROM library/ubuntu:16.04
RUN apt-get update
RUN apt-get install -y --no-install-recommends wget
RUN apt-get install -y --no-install-recommends clang-format

RUN wget --quiet http://cilk.mit.edu/tapir_1.0-2_amd64.deb
RUN apt-get install -y --no-install-recommends ./tapir_1.0-2_amd64.deb
RUN rm tapir_1.0-2_amd64.deb


RUN wget --quiet http://f.wsmoses.com/fib.c
RUN apt-get install -y libomp5
RUN clang fib.c -fcilkplus -ftapir=openmp -fopenmp
RUN ./a.out
