#!/bin/bash
#
#SBATCH --job-name=GLM_rca1-1_S1_L001
#SBATCH --output=/project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/log_files/GLM_rca1-1_S1_L001.%j.out
#SBATCH --error=/project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/log_files/GLM_rca1-1_S1_L001.%j.err
#SBATCH --time=48:00:00
#SBATCH -p standard
#SBATCH --account=cphg-millerlab
#SBATCH --nodes=1
#SBATCH --mem=150Gb
#SBATCH --dependency=afterok:65073199:65073200
#SBATCH --kill-on-invalid-dep=yes
module load miniforge
conda activate diff-splicing-analysis
module load star/2.7.11b
module load gcc/11.4.0
module load openmpi/4.1.4
module load R/4.4.1
pip3 install -r /project/cphg-millerlab/christine_tsai/01-diff-splice/SICILIAN/requirements.txt
date
Rscript scripts/GLM_script_light.R /project/cphg-millerlab/christine_tsai/01-diff-splice//02-outputs/rca1-1_S1_L001/ /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/gtf_file/grch38_known_genes.gtf  0  0  0 /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/domain_file/ucscGenePfam.txt /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/exon_pickle_file/hg38_refseq_exon_bounds.pkl /project/cphg-millerlab/christine_tsai/01-diff-splice/00-inputs/SICILIAN_human_hg38_Refs/splice_pickle_file/hg38_refseq_splices.pkl 
date
