 #!/bin/bash

THREADS=16
DIAMOND_DB=/data/diamondDB/nr.dmnd
MEGAN_DB=/data/diamondDB/megan-map-May2020.db
DATASTORE=/mnt/storage/FPES/FPES
SAMPLEDIR=sample_fasta
CLASSDIR=megan_LR

cd "$DATASTORE"

if [ ! -d "$CLASSDIR" ]; then
        mkdir "$CLASSDIR"
fi

# for FASTA in $(find "$SAMPLEDIR" -name "*.fastq"); do
#   SAMPLE=$(basename "$FASTA");
#   SAMPLE=${SAMPLE/.qcreads.fastq/};
#   printf "\n$SAMPLE\n\n"
#   if [ ! -f "$CLASSDIR"/"$SAMPLE".longreads.daa ]; then
#     diamond blastx --long-reads -d "$DIAMOND_DB" -q "$FASTA" --outfmt 100 --out "$CLASSDIR"/"$SAMPLE".longreads.daa -c3 -b5 --tmpdir /dev/shm
#   fi
#   if [ ! -s "$CLASSDIR"/"$SAMPLE".longreads.daa ]; then
#     echo "Failed to build, retrying"
#     rm "$CLASSDIR"/"$SAMPLE".longreads.daa
#     diamond blastx --long-reads -d "$DIAMOND_DB" -q "$FASTA" --outfmt 100 --out "$CLASSDIR"/"$SAMPLE".longreads.daa -c2 -b6 --tmpdir /dev/shm
#   fi

done

for FASTA in $(find "$SAMPLEDIR" -name "*.fastq"); do
  SAMPLE=$(basename "$FASTA");
  SAMPLE=${SAMPLE/.qcreads.fastq/};
  printf "\n$SAMPLE\n\n"
  if [ -f "$CLASSDIR"/"$SAMPLE".longreads.daa ]; then
        ~/megan/tools/daa-meganizer -i "$CLASSDIR"/"$SAMPLE".longreads.daa \
        --mapDB "$MEGAN_DB" --longReads --lcaAlgorithm longReads \
        --lcaCoveragePercent 51 --readAssignmentMode alignedBases -t "$THREADS"
    fi
done
