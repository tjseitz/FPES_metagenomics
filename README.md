# FPESmetagenomics-practice
Practice using DIAMOND and MEGAN to taxonomically classify FPES metagenomics samples

---

### Database locations:

Diamond `/data/diamondDB/nr.dmnd`

MEGAN `/data/diamondDB/meganmap-may2020.db`

### Creating a smaller sample subset

Using [seqtk](https://github.com/lh3/seqtk)

`seqtk sample -s100 reads.fastq 5000 > reads_sub5k.fastq`

For this one the file we are copying a random sample from is *reads.fastq*, the sample is of 5000 reads, and the new file being created is *reads_sub5k.fastq*


### Using DIAMOND to align my sample reads

```
diamond blastx -d /data/diamondDB/nr.dmnd -q FPES_20180719A.bc04.sub.fastq --range-culling --top 10 -F 15 --outfmt 100 -o FPES_20180719A.bc04.sub100k 
```

This is using options for range culling (designed for long reads), output format (.daa), top (report alignments in given range), and frameshifts (-F).

These options are based on those in [Arugmugan et al. (2019)](https://doi.org/10.1186/s40168-019-0665-y)


### Use MEGAN daa-meganizer to prep .daa file for further exploration in MEGAN

*Note: the default memory usage for MEGAN is set to only 2Gb which causes the daa-meganizer to crash. This was manually changed to 8Gb*

```
./daa-meganizer -i ~/FPESprac_202006/FPES_20180719A.bc04.sub100k.daa --longReads --lcaAlgorithm longReads --lcaCoveragePercent 51 --readAssignmentMode alignedBases --mapDB  /data/diamondDB/megan-map-May2020.db -v
```

Again, these options are based on those in [Arugmugan et al. (2019)](https://doi.org/10.1186/s40168-019-0665-y)




