#!/bin/bash

# reset RNASEQ_env variables
export RNASEQ_ROOT="";
export RNASEQ_SCRATCH="";
export RNASEQ_JOB_IDENT="";
export RNASEQ_FASTA="";
export RNASEQ_GTF="";
export RNASEQ_SRA_ID="";
export RNASEQ_SRA_LIST="";
export RNASEQ_READ_LENGTH="";
export INSTALL_STATUS="";

# parse inputs from command line, otherwise drop to interactive, or do solo-install
while getopts ":h-:" opt; do
 case ${opt} in
  h)
   # -h flag
   echo "Usage: ./workflow [options] <default: interactive>;"
   echo "	Options:";
   echo "		--install 			<loc>   install build folder to location <default NO>";
   echo "		--check				<loc>	check location for working installation";
   echo "		--root				<loc>	installation directory <default: interactive>";
   echo "		--scratch			<loc>	scratch installation directory <default: interactive>"
   echo "		--SRRlist 			<loc>	line delimited file with SRR ids <default: interactive>";
   echo "		--SRRid		 		<SRR>	process single SRR accession <default: interactive>";
   echo "		--fasta 			<loc>	location for GRCh38 fasta <default: interactive>";
   echo "		--gtf				<loc>	location for GRCh38 gtf <default: interactive>"; 
   echo "		--read_len			<int>	size of read <default: interactive>";
   echo "		--prefix			<str>	job name / id <default: interactive>";
   exit 0;
   ;;
  -)
   case "${OPTARG}" in	
    install)
     echo "Installing source distributables then exiting.";
     HOLD="${!OPTIND}";
     export RNASEQ_ROOT=`readlink -f $HOLD`;
     OPTIND=$(( $OPTIND + 1 ));
     mkdir -p $RNASEQ_ROOT;
     cd $RNASEQ_ROOT;
     git init .;
     git remote add -t \* -f origin https://github.com/mforde84/RNASEQ_Workflow;
     git checkout master;
     bash $RNASEQ_ROOT/scripts/script.0d.installation.sh;
     exit;
    ;;
    check)
	 echo "Checking for working installation.";
     HOLD="${!OPTIND}";
     export RNASEQ_ROOT=`readlink -f $HOLD`;
     OPTIND=$(( $OPTIND + 1 ));
     mkdir -p $RNASEQ_ROOT;
     cd $RNASEQ_ROOT;
	 bash $RNASEQ_ROOT/scripts/script.0e.check.installation.sh;
	 exit;
    ;;
    root)
     HOLD="${!OPTIND}";
     export RNASEQ_ROOT=`readlink -f $HOLD`;
     OPTIND=$(( $OPTIND + 1 ));
     ;;
    scratch)
     HOLD="${!OPTIND}";
     export RNASEQ_SCRATCH=`readlink -f $HOLD`;
     OPTIND=$(( $OPTIND + 1 ));
    ;;
    SRRlist)
     HOLD="${!OPTIND}";
     export RNASEQ_SRA_LIST=`readlink -f $HOLD`;
     OPTIND=$(( $OPTIND + 1 ));
    ;;
    SRRid)
     export RNASEQ_SRA_ID="${!OPTIND}";
     OPTIND=$(( $OPTIND + 1 ));
    ;;
    fasta)
     HOLD="${!OPTIND}";
     export RNASEQ_FASTA=`readlink -f $HOLD`;
     OPTIND=$(( $OPTIND + 1 ));
    ;;  
    gtf)
     HOLD="${!OPTIND}";
     export RNASEQ_GTF=`readlink -f $HOLD`;
     OPTIND=$(( $OPTIND + 1 ));
    ;;
    read_len)
     export RNASEQ_READ_LENGTH="${!OPTIND}";
     OPTIND=$(( $OPTIND + 1 ));
    ;;
    prefix)
     export RNASEQ_JOB_IDENT="${!OPTIND}";
     OPTIND=$(( $OPTIND + 1 ));
    ;;
   esac;
  ;;
  ?)
   echo "";
   echo "Unrecognized command, exiting";
   echo "./workflow.sh -h # for help";
   exit;
  ;;
 esac;
done;

# load functions 
source $(readlink -f .)"/scripts/script.0a.functions.sh";

# grab interactives
source $(readlink -f .)"/scripts/script.0b.interactive.query.sh";

# set runtime environment variables
cd $RNASEQ_ROOT;
source "$RNASEQ_ROOT""/scripts/script.0c.environment.variables.sh";

# if no suitable installation found exit script
source $RNASEQ_ROOT/scripts/script.0e.check.installation.sh;
if [ "$INSTALL_STATUS" == "1" ]; then
 exit 0;
fi

#1st pass index
export INDEX=`qsub -V $RNASEQ_ROOT/scripts/script.1.index.reference.pbs -o "$RNASEQ_SCRATCH"/logs/"$RNASEQ_JOB_IDENT" -N log.index.1 | sed 's/\..*//g';`;

#download and 1st alignment
unset ALIGN1;
while read -r line; do

 #download files
 export INPUT_FILE=$line;
 export DOWNLOAD=`qsub -o $RNASEQ_SCRATCH/logs/$RNASEQ_JOB_IDENT -W depend=afterok:$INDEX -N log.sra.download.$INPUT_FILE -V $RNASEQ_ROOT/scripts/script.2.sra.download.pbs | sed 's/\..*//g';`;
 
 #run 1st pass align
 export ALIGN1=`qsub -o $RNASEQ_SCRATCH/logs/$RNASEQ_JOB_IDENT -W depend=afterok:$DOWNLOAD -N log.1stpass.$INPUT_FILE -V $RNASEQ_ROOT/scripts/script.3.star1.align.pbs | sed 's/\..*//g';`":""$ALIGN1";

done < "$RNASEQ_SRA_LIST"

#cleanup trailing : on 1st past align dependancies
export ALIGN1=`echo $ALIGN1 | sed 's/:$//g'`;

#reindex
export REINDEX=`qsub -o $RNASEQ_SCRATCH/logs/$RNASEQ_JOB_IDENT -N log.index.2 -W depend=afterany:$ALIGN1 -V $RNASEQ_ROOT/scripts/script.4.sjout.reindex.pbs | sed 's/\..*//g';`;

# second pass, sort, & count
while read -r line; do

 export INPUT_FILE=$line;

 #2nd pass align
 export ALIGN2=`qsub -o $RNASEQ_SCRATCH/logs/$RNASEQ_JOB_IDENT -W depend=afterok:$REINDEX -N log.2ndpass.$INPUT_FILE -V $RNASEQ_ROOT/scripts/script.5.star2.align.pbs | sed 's/\..*//g';`;
 
 #sort by read name
 export SORT=`qsub -o $RNASEQ_SCRATCH/logs/$RNASEQ_JOB_IDENT -W depend=afterok:$ALIGN2 -N log.sort.$INPUT_FILE -V $RNASEQ_ROOT/scripts/script.6.sort.pbs | sed 's/\..*//g';`;
 
 #count reads
 export COUNT=`qsub -o $RNASEQ_SCRATCH/logs/$RNASEQ_JOB_IDENT -W depend=afterok:$SORT -N log.count.$INPUT_FILE -V $RNASEQ_ROOT/scripts/script.7.count.pbs | sed 's/\..*//g';`;
 
done < "$RNASEQ_SRA_LIST"

