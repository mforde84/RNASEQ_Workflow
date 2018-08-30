#!/bin/bash

#### set general env variables for software installation
export PATH=$RNASEQ_ROOT/build/bin:$PATH;
export JAVA_HOME=$RNASEQ_ROOT/build;
export PYTHONPATH=$RNASEQ_ROOT/build;
export LD_LIBRARY_PATH=$RNASEQ_ROOT/build/lib:$LD_LIBRARY_PATH;
export LD_LIBRARY_PATH=$RNASEQ_ROOT/build/lib64:$LD_LIBRARY_PATH;
export LD_LIBRARY_PATH=$RNASEQ_ROOT/build/lib:$LD_LIBRARY_PATH;
export LD_LIBRARY_PATH=$RNASEQ_ROOT/build/lib/gcc/x86_64-unknown-linux-gnu/6.4.0:$LD_LIBRARY_PATH;
export PERL5LIB=$RNASEQ_ROOT/build/lib/perl5/site_perl/5.28.0/x86_64-linux-thread-multi;
export CPATH=$RNASEQ_ROOT/build/include:$CPATH;
export CPATH=$RNASEQ_ROOT/build/include/python2.7:$CPATH;
export CFLAGS="-fPIC -I$RNASEQ_ROOT/build/include";
export CXXFLAGS="-fPIC -I$RNASEQ_ROOT/build/include";
export CPPFLAGS="-fPIC -I$RNASEQ_ROOT/build/include";
export LDFLAGS="-L$RNASEQ_ROOT/build/lib";
export CC="gcc";
export FC="gfortran";
export F90="gfortran";
export F77="gfortran";
export CPP="gcc -E";
export CXX="g++";
export LC_ALL="en_US.UTF-8";
