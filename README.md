# FPES metagenomics
Use [Diamond](#diamond), [MEGAN](#megan), and [Kraken2](#kraken2) to classify taxonomy and function of 2018/19 FPES metagenomes

---

### Database locations:

Diamond `/data/diamondDB/nr.dmnd`

MEGAN `/data/diamondDB/meganmap-may2020.db`

Kraken2 `/data/kraken2_drown_microbial_2020`

### Creating a smaller sample subset

Using [seqtk](https://github.com/lh3/seqtk)

`seqtk sample -s100 reads.fastq 5000 > reads_sub5k.fastq`

For this one the file we are copying a random sample from is *reads.fastq*, the sample is of 5000 reads, and the new file being created is *reads_sub5k.fastq*

---

## Diamond

### Using Diamond to align my sample reads

```
diamond blastx -d /data/diamondDB/nr.dmnd -q FPES_20180719A.bc04.sub.fastq --range-culling --top 10 -F 15 --outfmt 100 -o FPES_20180719A.bc04.sub100k 
```

This is using options for range culling (designed for long reads), output format (.daa), top (report alignments in given range), and frameshifts (-F).

These options are based on those in [Arugmugan et al. (2019)](https://doi.org/10.1186/s40168-019-0665-y)

---

## MEGAN

### Use MEGAN daa-meganizer to prep .daa file for further exploration in MEGAN

*Note: the default memory usage for MEGAN is set to only 2Gb which causes the daa-meganizer to crash. This was manually changed to 8Gb*

```
./daa-meganizer -i ~/FPESprac_202006/FPES_20180719A.bc04.sub100k.daa --longReads --lcaAlgorithm longReads --lcaCoveragePercent 51 --readAssignmentMode alignedBases --mapDB  /data/diamondDB/megan-map-May2020.db -v
```

Again, these options are based on those in [Arugmugan et al. (2019)](https://doi.org/10.1186/s40168-019-0665-y)

### Rename your samples to a more useful label

Use the script [sample-locations](sample-locations) to copy and rename your original fasta/q files


**If you want to run more than one sample through Diamond and the meganizer, I would use the script** [megan_prep.sh](megan_prep.sh) **which will run your data through Diamond and then the daa-meganizer**



---

## Kraken2

### Use Kraken2 + Bracken to classify taxonomy

Use [classify_FPES.sh](classify_FPES.sh) with whatever Bracken read length option (or all)

The lowest portion is normalizing each mpa report, these will be used later for abundance analysis

### Merge mpa (metaphlan) files from all samples

Make sure to specify which normalized files you are using at \*\.norm, in this case use Bracken mpa with read length "500"

The scripts used in this next section are located in the [BNZ_metagenomics] (https://github.com/devindrown/BNZ_metagenomics.git) repo

*remember to change the name from "merge_metaphlan.txt" to whatever data I am actually working with!*

```
/mnt/storage/BNZ_metagenomics/scripts/merge_metaphlan_tables.py mpa/*.norm >  merge_metaphlan.txt
```
This is what your newly merged file will look like if you open in Excel (samples across the columns, with each row being a classification):

![](https://github.com/tjseitz/FPESmetagenomics/blob/master/merged_mpa_%20bracken500.png?raw=true)



These next few lines are some examples of what you can use to make heatmaps based on bray-curtis distance (however, there is little you can control so I would use *pheatmap* in R, which I think you can control the distance measure and cosmetics a lot better)


If you want a heatmap of the top most abundant 25 families in your sample:
```
/mnt/storage/BNZ_metagenomics/scripts/metaphlan_hclust_heatmap1.7mod.py --in merge_metaphlan.txt  --top 25 --minv 0.1 -s log --out merge_metaphlan_heatmap.png -f braycurtis -d braycurtis --tax_lev f
```


If you want top 150 most abundant species:
```
/mnt/storage/BNZ_metagenomics/scripts/metaphlan_hclust_heatmap1.7mod.py --in merge_metaphlan.txt  --top 150 --minv 0.1 -s log --out merge_metaphlan_heatmap_big.png -f braycurtis -d braycurtis --tax_lev s
```


Soooo, those last two things are helpful if you want to find out the most abundant to a specific taxonomic level, for example, use it to find the top 10 families, but in order to actually make nice heatmaps, you probably want to **clean** your data a bit

**Generate species/family/phlya only abundance table**

In order to pare down your data from super long, messy taxonomy headers at all levels of classification use this the following line (I was working with the previously merged file "merge_metaphlan_bracken500.txt"):

```
grep -E "(f__)|(^ID)" merge_metaphlan_bracken500.txt | grep -v "g__" | sed 's/^.*f__//g' > merge_abundance_family.txt
```

The first part of the command is any header row for the *family* level (f__) and matches to ID/samples. Note the **two** underscores there! The second grep doesn't print any lines that go to the genus level (g__). The sed then removes the full taxonomy from each line and instead leaves only the f__ family name in this case.

After you run this command, this is what your merged file will look like:

![](https://github.com/tjseitz/FPESmetagenomics/blob/master/merged_mpa_family.png?raw=true)

This is a helpful link for learning about what to do with your mpa file:

[Metaphlan2](https://github.com/biobakery/biobakery/wiki/metaphlan2#create-a-heatmap-with-hclust2)

Try this out once you have the merged mpa for an additional type of analysis:

[LEfSe](http://huttenhower.org/galaxy/)
