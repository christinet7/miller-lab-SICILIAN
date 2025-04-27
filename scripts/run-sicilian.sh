#!/bin/bash


#SBATCH --time=12:00:00
#SBATCH -A myaccount

module load anaconda/2023.07-py3.11
conda activate diff-splicing-analysis

python3 sicilian.py
