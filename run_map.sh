#!/bin/bash
#
#SBATCH --job-name=map_rca1-1_S1_L001
#SBATCH --output=/project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/log_files/map_rca1-1_S1_L001.%j.out
#SBATCH --error=/project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/log_files/map_rca1-1_S1_L001.%j.err
#SBATCH --time=24:00:00
#SBATCH -p standard
#SBATCH --account=cphg-millerlab
#SBATCH --nodes=1
#SBATCH --mem=60Gb
module load miniforge
module load star/2.7.11b
conda activate diff-splicing-analysis
module load gcc/11.4.0
module load openmpi/4.1.4
module load R/4.4.1
date
mkdir -p /project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001
/project/cphg-millerlab/christine_tsai/01-diff-splice/SICILIAN/STAR/STAR_2.7.11b/Linux_x86_64/STAR --version
/project/cphg-millerlab/christine_tsai/01-diff-splice/SICILIAN/STAR/STAR_2.7.11b/Linux_x86_64/STAR --runThreadN 4 --genomeDir /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/star_ref_file/hg38_ERCC_STAR_2.7.5.a --readFilesIn /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/rca1-1_S1_L001_R1_001.fastq.gz --readFilesCommand zcat --twopassMode Basic --alignIntronMax 1000000 --outFileNamePrefix /project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/1 --outSAMtype BAM Unsorted --outSAMattributes All --chimOutType WithinBAM SoftClip Junctions --chimJunctionOverhangMin 10 --chimSegmentReadGapMax 0 --chimOutJunctionFormat 1 --chimSegmentMin 12 --chimScoreJunctionNonGTAG -4 --chimNonchimScoreDropMin 10 --quantMode GeneCounts --sjdbGTFfile /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/gtf_file/grch38_known_genes.gtf --outReadsUnmapped Fastx 

/project/cphg-millerlab/christine_tsai/01-diff-splice/SICILIAN/STAR/STAR_2.7.11b/Linux_x86_64/STAR --runThreadN 4 --genomeDir /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/star_ref_file/hg38_ERCC_STAR_2.7.5.a --readFilesIn /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/rca1-1_S1_L001_R2_001.fastq.gz --readFilesCommand zcat --twopassMode Basic --alignIntronMax 1000000 --outFileNamePrefix /project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/2 --outSAMtype BAM Unsorted --outSAMattributes All --chimOutType WithinBAM SoftClip Junctions --chimJunctionOverhangMin 10 --chimSegmentReadGapMax 0 --chimOutJunctionFormat 1 --chimSegmentMin 12 --chimScoreJunctionNonGTAG -4 --chimNonchimScoreDropMin 10 --quantMode GeneCounts --sjdbGTFfile /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/gtf_file/grch38_known_genes.gtf --outReadsUnmapped Fastx 


date
