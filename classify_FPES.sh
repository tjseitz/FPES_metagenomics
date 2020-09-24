#!/bin/bash

LEVEL=S
THRESHOLD=10
THREADS=16
KRAKEN_DB=/data/kraken2_drown_microbial_2020
DATASTORE=/mnt/storage/FPES/FPES
SAMPLEDIR=sample_fasta
CLASSDIR=classification

cd "$DATASTORE"

if [ ! -d "$CLASSDIR" ]; then
        mkdir "$CLASSDIR"
fi
if [ ! -d "$CLASSDIR"/kraken ]; then
        mkdir "$CLASSDIR"/kraken
fi
if [ ! -d "$CLASSDIR"/bracken ]; then
        mkdir "$CLASSDIR"/bracken
fi

if [ ! -d "$CLASSDIR"/mpa ]; then
        mkdir "$CLASSDIR"/mpa
fi


 for FASTA in $(find "$SAMPLEDIR" -name "*.fastq"); do
   SAMPLE=$(basename "$FASTA");
   SAMPLE=${SAMPLE/.qcreads.fastq/};
   printf "\n$SAMPLE\n\n"
    kraken2 --db ${KRAKEN_DB} --threads ${THREADS} --report-zero-counts --report "$CLASSDIR"/${SAMPLE}.kreport "$FASTA" > "$CLASSDIR"/kraken/${SAMPLE}.kraken
    kraken2 --db ${KRAKEN_DB} --threads ${THREADS} --report-zero-counts --use-mpa-style --report "$CLASSDIR"/mpa/${SAMPLE}.mpa.kreport "$FASTA" > "$CLASSDIR"/kraken/${SAMPLE}.mpa.kraken
   for READ_LEN in {100,500,1000}; do
       bracken -d ${KRAKEN_DB} -i "$CLASSDIR"/${SAMPLE}.kreport -o "$CLASSDIR"/bracken/${SAMPLE}.${READ_LEN}.bracken -w "$CLASSDIR"/${SAMPLE}.${READ_LEN}.bracken.${LEVEL}.kreport -r ${READ_LEN} -l ${LEVEL} -t ${THRESHOLD}
       /mnt/storage/BNZ_metagenomics/scripts/kreport2mpa.py -r "$CLASSDIR"/${SAMPLE}.${READ_LEN}.bracken.${LEVEL}.kreport -o "$CLASSDIR"/mpa/${SAMPLE}.${READ_LEN}.bracken.${LEVEL}.mpa.kreport
   done
 done

for MPAREPORT in $(find "$CLASSDIR"/mpa -name "*.mpa.kreport"); do
  sum=$(grep -vP "\|" "$MPAREPORT" | cut -f 2 | awk '{sum += $1} END {printf ("%.2f\n", sum/100)}')
  awk -v sum="$sum" 'BEGIN {FS="\t"} {OFS="\t"} {print $1,$2/sum}' "$MPAREPORT" > "$MPAREPORT".norm
done



