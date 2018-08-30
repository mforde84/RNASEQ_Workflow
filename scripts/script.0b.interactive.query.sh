#!/bin/bash

########################
##### set work directory
########################

# challenge default root directory location
challenge_default RNASEQ_ROOT `pwd`;
if [ ! -d "$RNASEQ_ROOT" ]; then
 mkdir -p $RNASEQ_ROOT || echo "You don't have permission to create this work directory";
 if [[ `pwd` != "$RNASEQ_ROOT" ]]; then
  cd $RNASEQ_ROOT || exit 0;
  git clone git clone https://github.com/mforde84/rnaseq_workflow_gardner .;
 fi;
fi;

# challenge default scratch directory location
challenge_default RNASEQ_SCRATCH `pwd`;
if [ ! -d "$RNASEQ_SCRATCH" ]; then
 mkdir -p $RNASEQ_SCRATCH || echo "You don't have permission to create this scratch directory";
 if [[ `pwd` != "$RNASEQ_SCRATCH" ]]; then
  cd $RNASEQ_SCRATCH || exit 0;
 fi;
fi;

##########################
##### set genome locations
##########################

# challenge default locations and genome selections
challenge_default RNASEQ_FASTA "/group/referenceFiles/Homo_sapiens/Ensembl/martin_g37_g38/g38/Homo_sapiens.GRCh38.dna.primary_assembly.fa";
challenge_default RNASEQ_GTF "/group/referenceFiles/Homo_sapiens/Ensembl/martin_g37_g38/g38/Homo_sapiens.GRCh38.92.gtf"; 

# seperate out the filenames
export FASTA=`echo $RNASEQ_FASTA | sed 's/^.*\///g'`
export GTF=`echo $RNASEQ_GTF | sed 's/^.*\///g'` 

#################################
##### set genome indexing options
#################################

# read length for star indexing
challenge_default RNASEQ_READ_LENGTH "100";

####################
##### job identifier
####################

# challenge base filename job identifier
challenge_default RNASEQ_JOB_IDENT `date +%Y.%m.%d.%Hh.%Mm`;

# challenge location of sra asseccion list
if [ "$RNASEQ_SRA_ID" == "" ]; then
 challenge_default RNASEQ_SRA_LIST $RNASEQ_ROOT/scripts/sra_download_list;
else
 echo $RNASEQ_SRA_ID > $RNASEQ_ROOT/scripts/sra_download_list;
 export RNASEQ_SRA_LIST=$RNASEQ_ROOT/scripts/sra_download_list;
fi;

########################################
##### check if working directories exist
########################################

# logs folder
if [ ! -d "$RNASEQ_SCRATCH"/logs/"$RNASEQ_JOB_IDENT" ]; then
 mkdir -p $RNASEQ_SCRATCH/logs/"$RNASEQ_JOB_IDENT";
fi;

# generate reference directories
mkdir -p $RNASEQ_ROOT/references/"$FASTA"_"$GTF"_"$RNASEQ_READ_LENGTH"bp/2pass;
ln -s $RNASEQ_FASTA $RNASEQ_ROOT/references/"$FASTA"_"$GTF"_"$RNASEQ_READ_LENGTH"bp/genome.fa;
ln -s $RNASEQ_GTF $RNASEQ_ROOT/references/"$FASTA"_"$GTF"_"$RNASEQ_READ_LENGTH"bp/genes.gtf;
ln -s $RNASEQ_FASTA $RNASEQ_ROOT/references/"$FASTA"_"$GTF"_"$RNASEQ_READ_LENGTH"bp/2pass/genome.fa;
ln -s $RNASEQ_GTF $RNASEQ_ROOT/references/"$FASTA"_"$GTF"_"$RNASEQ_READ_LENGTH"bp/2pass/genes.gtf;

# data folder
if [ ! -d "$RNASEQ_SCRATCH"/data/"$RNASEQ_JOB_IDENT" ]; then
 mkdir $RNASEQ_SCRATCH/data/"$RNASEQ_JOB_IDENT"/intermediate
 mkdir $RNASEQ_SCRATCH/data/"$RNASEQ_JOB_IDENT"/reads
fi

# results folder
if [ ! -d "$RNASEQ_ROOT"/results/"$RNASEQ_JOB_IDENT" ]; then
 mkdir -p $RNASEQ_ROOT/results/"$RNASEQ_JOB_IDENT"/bams;
 mkdir $RNASEQ_ROOT/results/"$RNASEQ_JOB_IDENT"/counts;
fi
