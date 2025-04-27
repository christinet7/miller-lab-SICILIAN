#!/bin/bash
#
#SBATCH --job-name=class_input_rca1-1_S1_L001
#SBATCH --output=/project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/log_files/class_input_rca1-1_S1_L001.%j.out
#SBATCH --error=/project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/log_files/class_input_rca1-1_S1_L001.%j.err
#SBATCH --time=48:00:00
#SBATCH -p standard
#SBATCH --account=cphg-millerlab
#SBATCH --nodes=1
#SBATCH --mem=200Gb
#SBATCH --dependency=afterok:65073199
#SBATCH --kill-on-invalid-dep=yes
module load miniforge
source activate diff-splicing-analysis
date
python3 scripts/light_class_input.py --outpath /project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/ --gtf /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/gtf_file/grch38_known_genes.gtf --annotator /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/annotator_file/hg38_refseq.pkl --bams /project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/1Aligned.out.bam /project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/2Aligned.out.bam --stranded_library --paired 
date
