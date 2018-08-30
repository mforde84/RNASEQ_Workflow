# CRI - Seminar Series: RNASEQ_Workflow
Workflow for analysis of RNAseq reads from SRA accession numbers on Gardner HPC.

Includes software distributable built from source, and automation scripts for genome indexing, alignments, gene / transcript level counts and normalizations. 

Request access here: https://cri-app02.bsd.uchicago.edu/WebProvisioning/Service.aspx?category=1&type=10

```bash
###for clone
git config --global http.sslverify false
git clone https://git.cri.uchicago.edu/mforde/RNASEQ_Workflow

###for commit
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
git remote set-url origin git@git.cri.uchicago.edu:mforde/RNASEQ_Workflow.git
git add .
git commit -m "<COMMENT>"
git push origin master
```
