###############
##### FUNCTIONS
###############

# if challenge != NULL, then change default var
challenge_default() {
 #check if variable already has value assigned
 #if not ask and challenge provided default
 #otherwise assume variable was passed as command line argument
 eval "FLAG=\$$1"
 export `echo $1`=$2;
 if [[ $FLAG == "" ]]; then
  echo -n "Use default path ($1=$2): ";
  read -r challenge_response;
  if [[ $challenge_response != "" ]]; then
   export `echo $1`=$challenge_response;
  fi;
 fi
}

# general installation scheme for software build
make_install() {
 echo "INSTALLING $1";
 cd $RNASEQ_ROOT/dist/$1;
 ./configure --prefix=$RNASEQ_ROOT/build --enable-shared > $RNASEQ_ROOT/logs/"$1".config.log;
 make > $RNASEQ_ROOT/logs/"$1".make.log;
 make install PREFIX=$RNASEQ_ROOT/build > $RNASEQ_ROOT/logs/"$1".makeinstall.log && echo "$1"" INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "$1"" FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
}

# general installation scheme for python build
make_install_python() {
 echo "INSTALLING $1";
 cd $RNASEQ_ROOT/dist/$1;
 python setup.py install > $RNASEQ_ROOT/logs/pip_"$1".install && echo "$1"" INSTALLED" >> $RNASEQ_ROOT/logs/INSTALL.LOG || echo "$1"" FAILED" >> $RNASEQ_ROOT/logs/INSTALL.LOG;
}
