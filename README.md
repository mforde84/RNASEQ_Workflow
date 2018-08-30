# CRI - Seminar Series: RNASEQ_Workflow
Workflow for STAR 2pass processing of RNAseq reads from SRA accession numbers on Torque/PBS HPC.

Usage:
$ ./workflow <options> <-h / help> <default: interactive>
  
Features
  1) software redistributable built from source
  2) automated qsub scripting for indexing, alignments, and gene level raw counts
  3) single and batch sample processing
  4) optional separation and reusable installation / results and scratch directories
  5) supports both CLI and interactive workflow submission
  
