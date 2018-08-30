#!/bin/bash

#### sources
source $RNASEQ_ROOT/scripts/script.0a.functions.sh;
source $RNASEQ_ROOT/scripts/script.0c.environment.variables.sh;

#### if build directory exists, assume software install works

if [ -d $RNASEQ_ROOT/build ]; then

 # if dir exists then stout that build directory exists
 echo "";
 echo "$RNASEQ_ROOT""/build exists."
 echo "  If you'd like to reinstall, then remove the directory"
 echo "  or select a new installation location.";
 echo "";
 
 # check status of installation
 bash $RNASEQ_ROOT/scripts/script.0e.check.installation.sh;
 
else

 #### generate build location
 mkdir -p $RNASEQ_ROOT/build;
 mkdir $RNASEQ_ROOT/logs;
 
 #### untar distributables
 echo "Decompressing software distributables";
 cd $RNASEQ_ROOT/dist;
 for f in *xz; do echo "Extracting $f"; tar xf $f; done;
 for f in *gz; do echo "Extracting $f"; tar zxf $f; done;

 #### jdk8 install
 echo "INSTALLING JDK8";
 cd $RNASEQ_ROOT/dist;
 cat jdk2 >> jdk1;
 tar zxf jdk1;
 mv $RNASEQ_ROOT/dist/jdk1.8.0_181/* $RNASEQ_ROOT/build;
 echo "JDK8 INSTALLED" > $RNASEQ_ROOT/logs/INSTALL.LOG;

 #### gcc/6.4.0 install
 # compiles with system default gcc
 echo "INSTALLING GCC/6.4.0 -- this will take a long time (6-8hr), just FYI";
 cd $RNASEQ_ROOT/dist/gcc-6.4.0;
 ./configure --prefix=$RNASEQ_ROOT/build --enable-shared --enable-languages=c,c++,fortran > $RNASEQ_ROOT/logs/gcc.config.log;
$(which expect) <<EOD
spawn make > $RNASEQ_ROOT/logs/gcc.make.log
expect {
-re "Archive name" { exp_send ".\r" exp_continue }
-re . { exp_continue }
timeout { exp_continue }
eof { return 0 }
}
EOD
 make >> $RNASEQ_ROOT/logs/gcc.make.log;
 make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/gcc.makeinstall.log && echo "GCC INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "GCC FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
 
######### TODO for kallisto build 
 #### cmake/3.12 install
 #echo "INSTALLING CMAKE/3.12";
 #cd $RNASEQ_ROOT/dist/CMake-3.12.0-rc3;
 #./bootstrap --prefix=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/cmake.config.log;
 #make > $RNASEQ_ROOT/logs/cmake.make.log;
 #make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/cmake.makeinstall.log && echo "CMAKE INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "CMAKE FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;

 #### autoconf installation
 make_install autoconf-2.69;

 #### install zlib
 make_install zlib-1.2.11;

 #### install bzip2
 echo "INSTALLING BZIP2/1.0.6";
 cd $RNASEQ_ROOT/dist/bzip2-1.0.6;
 make -f Makefile-libbz2_so > $RNASEQ_ROOT/logs/bzip.make.log; 
 cp libbz2.so.1.0.6 $RNASEQ_ROOT/build/lib/;
 cp *.h $RNASEQ_ROOT/build/include;
 ln -s $RNASEQ_ROOT/build/lib/libbz2.so.1.0.6 $RNASEQ_ROOT/build/lib/libbz2.so.1.0;
 make;
 make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/bzip2.makeinstall.log && echo "BZIP2 INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "BZIP2 FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
 
 #### install xz
 make_install xz-5.2.4;

 #### install pcre
 echo "INSTALLING PCRE/8.39";
 cd $RNASEQ_ROOT/dist/pcre-8.39;
 ./configure --enable-utf8 --prefix=$RNASEQ_ROOT/build --disable-cpp > $RNASEQ_ROOT/logs/pcre.config.log;
 make > $RNASEQ_ROOT/logs/pcre.make.log;
 make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/pcre.makeinstall.log && echo "PCRE INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "PCRE FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;

 #### perl5 installation
 echo "INSTALLING PERL/5.28.0";
 cd $RNASEQ_ROOT/dist/perl-5.28.0;
 ./Configure -des -Dusethreads -Dcc=gcc -Dprefix=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/perl.config.log;
 make > $RNASEQ_ROOT/logs/perl.make.log;
 cd $RNASEQ_ROOT/dist/perl-5.28.0/dist/IO/;
 sed -i 's/poll.h/sys\/poll.h/g' IO.c;
 gcc -c -D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector-strong -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2 -Wall -Werror=declaration-after-statement -Werror=pointer-arith -Wextra -Wc++-compat -Wwrite-strings -O2 -DVERSION=\"1.39\" -DXS_VERSION=\"1.39\" -fPIC "-I../.." IO.c; 
 cd $RNASEQ_ROOT/dist/perl-5.28.0;
 make >> $RNASEQ_ROOT/logs/perl.make.log;
 make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/perl5.makeinstall.log && echo "PERL5 INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "PERL5 FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
ls

 #### install python
 echo "INSTALLING PYTHON/2.7.15";
 cd $RNASEQ_ROOT/dist/Python-2.7.15;
 ./configure --prefix=$RNASEQ_ROOT/build --enable-shared --enable-optimizations > $RNASEQ_ROOT/logs/python.config.log;
 make > $RNASEQ_ROOT/logs/python.make.log;
 make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/python.makeinstall.log && echo "PYTHON INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "PYTHON FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
 cd $RNASEQ_ROOT/dist/setuptools-39.2.0;
 python bootstrap.py > $RNASEQ_ROOT/logs/pip_setuptools_bootstrap.log;
 make_install_python setuptools-39.2.0;
 make_install_python cython-0.28.3;
 make_install_python swig-re-3.0.12;
 make_install_python numpy-1.14.5;
 make_install_python pysam-0.14.1;
 make_install_python htseq-release_0.9.1;

 #### install openssl
 echo "INSTALLING OPENSSL/1.1.1-PRE8";
 cd $RNASEQ_ROOT/dist/openssl-1.1.1-pre8
 ./config --prefix=$RNASEQ_ROOT/build --openssldir=$RNASEQ_ROOT/build -L$RNASEQ_ROOT/build/lib -I$RNASEQ_ROOT/build/include > $RNASEQ_ROOT/logs/openssl.config.log;
 make > $RNASEQ_ROOT/logs/openssl.make.log;
 make install PREFIX=$RNASEQ_ROOT/build && echo "OPENSSL INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "OPENSSL FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;

 #### install curl
 make_install curl-7.60.0;
 
 #### install htslib
 cd $RNASEQ_ROOT/dist/htslib-1.8;
 autoreconf -i > $RNASEQ_ROOT/logs/htslib_reconf.log;
 make_install htslib-1.8;
 
 #### install samtools
 cd $RNASEQ_ROOT/dist/samtools-1.8;
 autoreconf -i > $RNASEQ_ROOT/logs/samtools_reconf.log;
 make_install samtools-1.8; 

 #### install STAR
 echo "INSTALLING STAR/2.5.3A";
 cd $RNASEQ_ROOT/dist/STAR-2.5.3a/source;
 make > $RNASEQ_ROOT/logs/star.make.log && echo "STAR INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "STAR FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
 mv $RNASEQ_ROOT/dist/STAR-2.5.3a/source/STAR $RNASEQ_ROOT/build/bin;

 #### install hdf5
 make_install hdf5-1.10.1;
 
 #### place fastq-dump binary
 cp "$RNASEQ_ROOT"/dist/fastq-dump "$RNASEQ_ROOT"/build/bin  && echo "FASTQ-DUMP INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "FASTQ-DUMP FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
 
######### TODO - kallisto and R stuff
 #### install kallisto
 #echo "INSTALLING KALLISTO/0.44.0";
 #cd $RNASEQ_ROOT/dist/kallisto-0.44.0/;
 #rm -rf $RNASEQ_ROOT/dist/kallisto-0.44.0/ext/htslib;
 #cp -r $RNASEQ_ROOT/dist/htslib-1.8 $RNASEQ_ROOT/dist/kallisto-0.44.0/ext/htslib;
 #mkdir $RNASEQ_ROOT/dist/kallisto-0.44.0/build;
 #cd $RNASEQ_ROOT/dist/kallisto-0.44.0/build;
 #cmake -DCMAKE_INSTALL_PREFIX=$RNASEQ_ROOT/build -DZLIB_INCLUDE_DIR=$RNASEQ_ROOT/build/include -DZLIB_LIBRARY_RELEASE=$RNASEQ_ROOT/build/lib/libz.so .. > $RNASEQ_ROOT/logs/kalliso.config.log;
 #make > $RNASEQ_ROOT/logs/kallisto.make.log
 #make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/kallisto.makeinstall.log && echo "KALLISTO INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "KALLISTO FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
 #### CRAN installation
 #echo "INSTALLING R/3.5.0";
 #cd $RNASEQ_ROOT/dist/R-3.5.0;
 #./configure --prefix=$RNASEQ_ROOT/build --enable-R-shlib > $RNASEQ_ROOT/logs/r.config.log;
 #make > $RNASEQ_ROOT/logs/r.make.log;
 #make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/r.makeinstall.log && echo "R INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "R FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG; 

 #### flag installation as complete
 echo "Installation complete";
 echo "EOF" >> $RNASEQ_ROOT/logs/INSTALL.LOG;

 #### check build status
 bash $RNASEQ_ROOT/scripts/script.0e.check.installation.sh;
 
fi
