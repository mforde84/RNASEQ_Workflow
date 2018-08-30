#!/bin/bash

echo "Checking status of installation:"
echo "";

#### sources
source $RNASEQ_ROOT/scripts/script.0c.environment.variables.sh;

#### if build directory exists, check log file for build status

if [ ! -d $RNASEQ_ROOT/build ]; then

 # if dir exists then stout that build directory exists
 echo "";
 echo "No $RNASEQ_ROOT""/build found."
 echo "  Please install with:"
 echo "  ./workflow --install $RNASEQ_ROOT"
 echo "";
 
else

 # if install script has completed then log will contain EOF
 export EOF_INSTALL=`tail -n1 $RNASEQ_ROOT/logs/INSTALL.LOG`;
 if [ "$EOF_INSTALL" == "EOF" ]; then #if EOF show build status
  echo "";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
  echo "~~~~~~~~~~ Installation script has completed ~~~~~~~~";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; 
  echo "";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
  echo "~~~~~~~~~~ Software failed installation~~~~~~~~~~~~~~";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
  grep FAIL $RNASEQ_ROOT/logs/INSTALL.LOG;
  echo "";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
  echo "~~~~~~~~~~ Software successfully installed ~~~~~~~~~~";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
  grep INSTALL $RNASEQ_ROOT/logs/INSTALL.LOG;
  echo "";
  # checkpoint for failed installations
  export FAIL_COUNT=`grep FAIL $RNASEQ_ROOT/logs/INSTALL.LOG | wc -l`;
  if [ $FAIL_COUNT == "0" ]; then # all installations successful
   # clean up packages distributables
   echo "BUILD SUCCESSFUL!"
   echo "Removing source distributions";
   cd $RNASEQ_ROOT;
   rm -rf $RNASEQ_ROOT/dist;
  else # failed installations
   echo "";
   echo "BUILD FAILED";
   echo "Leaving source directories intact.";
   echo "Please consult $RNASEQ_ROOT/logs for build details";
   echo "";
   export INSTALL_STATUS=1;
   exit;
  fi
 else #if not EOF show current progress
  echo "";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
  echo "~~~~~~~~~~ Installation script has NOT completed ~~~~";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; 
  echo "";
  echo "Current progress:";
  cat $RNASEQ_ROOT/logs/INSTALL.LOG;
  echo "";
  export INSTALL_STATUS=1;
 fi;

fi
