#!/bin/bash

#SBATCH -J indelgencalljob
#SBATCH -o indelgencalljob.o%j
#SBATCH -e indelgencalljob.e%j
#SBATCH -n 16
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH -A XXXX

SCRIPT="/home1/01499/oakglade/bin/GenomeAnalysisTK-2.7-2-g6bda569/GenomeAnalysisTK.jar" # Path to gatk, or you can use module load gatk
INDIR="/scratch/01499/oakglade/hallii_combined/08-gatk-indel-realign/realigned/" # Path to the realigned BAM files
OUT="/scratch/01499/oakglade/hallii_combined/11-gatk-first-unified-indel/inDels-Q30.vcf" # Path to inDels-Q20.vcf output file
REF="/scratch/01499/oakglade/hallii_reference/Panicum_hallii.main_genome.scaffolds.fasta" # Path to reference
FILES="files.list" # The name of the list of bam files to read into GATK. We will create this.
LOGS="snp-model.logs" # Name of the output log

# Check if the files list exists, and remove it if it does
if [ -e $FILES ]; then rm $FILES; fi
touch $FILES

# Loop through the realigned bam files and append the path to the files.list file
for fil in ${INDIR}*.bam; do
echo $fil >> $FILES
done

# Now run GATK for INDELs only
java -Xms5G -Xmx15G -jar $SCRIPT -T UnifiedGenotyper \
-nct 4 -nt 4 \
-I $FILES \
-stand_call_conf 20.0 \
-stand_emit_conf 20.0 \
-glm INDEL \
-gt_mode DISCOVERY -R $REF -o $OUT > $LOGS

echo "DONE";