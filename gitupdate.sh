#!/bin/bash
export COMMENT=$1;
export AGENT=$(eval $(ssh-agent -s) | sed 's/^.*pid //g');
ssh-add ~/.ssh/id_rsa;
git remote set-url origin git@git.cri.uchicago.edu:mforde/RNASEQ_Workflow.git
git add .;
git commit -m "$COMMENT";
git push origin master;
kill -9 $AGENT;
