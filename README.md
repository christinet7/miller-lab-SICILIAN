# Using SICILIAN for Differential Splicing Analysis
This serves as a guide for using SICILIAN through the UVA HPC.
## Description
[SICILIAN](https://github.com/salzman-lab/SICILIAN?tab=readme-ov-file) (SIngle Cell precIse spLice estImAtioN) is a statistical wrapper that uses generalized linear statistical modeling to obtain high-confidence splice junction quantification in single cells. 
## Getting Started

### Dependencies
Direct software dependencies include the following:
- Python
    - argparse
    - numpy
    - pandas
    - pyarrow
    - pysam
- R
    - data.table
    - glmnet
    - tictoc
    - dplyr
    - stringr
    - GenomicAlignments
    - cutpointr

Python package dependencies can be installed using the `pip3 install -r requirements.txt` command. 
    Side note: despite having the necessary python modules loaded in my conda environment, some modules like pandas were still not found despite showing up when using the `conda list` command. Thus, it is recommended to include a line in your slurm script (so edit the `sbatch_file()` function in SICILIAN.py so that each generated script for each process of the pipeline has the line).

R package dependencies are automatically checked for and installed by the SICILIAN R script. 

If using an Anaconda or Miniforge environment, you can check for package(s) of interest using the `conda list` command. Of the list of Python package dependencies, I personally found that argparse and pysam were missing from the `conda list` output. 
    
To further check if a specific package is installed you can use the following command: `python -c "import <package_name>"`. If you enter the command and see no output, that should be an indication that the package is already installed. If you enter the command and see a ModuleNotFoundError, you can use the `conda install -c <optional_channel_name> <package-name>` command. Note that when you activate your conda environment, the installed packages should persist every time you activate that environment. 

### Input Files
#### 1. Index and Annotator Files

##### Downloading SICILIAN's Ready-to-Use Index and Annotator Files
The SICILIAN repo provides several links for different species that enables you to download ready-to-use files which are needed for annotating splice junctions. For now, we will proceed with the assumption that we are interested in the Human hg38.

One way to download the tar file: `curl "https://drive.usercontent.google.com/download?id=1cGfn7MZbGewBJp6ZGGW_IOW3nWEAHOPz&confirm=xxx" -o SICILIAN_human_hg38_Refs.tar`
    Note: there may be some issues with downloading the tar file from the Google Drive link because the file is too large to be scanned for viruses, and instead of downloading the actual tar file of interest, using commands similar to `curl` may result in an HTML Google Virus Scan warning page being downloaded instead. 
    This issue was encountered when I used the following command: `curl https://drive.google.com/file/d/1cGfn7MZbGewBJp6ZGGW_IOW3nWEAHOPz/view?usp=sharing > SICILIAN_human_hg38_Refs.tar`

Once the tar file has been successfully downloaded, untar the tar file in the target directory using `tar xvf SICILIAN_human_hg38_Refs.tar` 

##### Breakdown of Folder Contents
The untarred folder should contain 5 subfolders: 
- annotator_file
    - Contains a pickle file used to pull gene names to add to identified junctions (e.g. ENSEMBL gene annotations)  
    - The file path for the file contained in this folder should be the value of the `annotator_file` variable in the `main()` function in SICILIAN.py
- domain_file
    - Contains a txt file which serves as the reference file for annotated protein domains 
    - The file path for the file contained in this folder should be the value of the `domain_file` variable in the `main()` function in SICILIAN.py, but it is an *optional* input
- exon_pickle_file
    - Contains a pickle file of the exon bounds (genomic coordsinates where each exon starts and ends)
    - The file path for the file contained in this folder should be the value of the `exon_pickle_file` variable in the `main()` function in SICILIAN.py, but it is an *optional* input
- gtf_file
    - Contains a GTF (gene transfer format) file which will be used as the reference annotation file 
    - The file path for the file contained in this folder should be the value of the `gtf_file` variable in the `main()` function in SICILIAN.py
- splice_pickle_file
    - Contains a pickle file 
    - The file path for the file contained in this folder should be the value of the `splice_pickle_file` variable in the `main()` function in SICILIAN.py, but it is an *optional* input
- star_ref_file
    - Contains STAR index files
    - The file path of this folder should be the value of the `star_ref_path` variable in the `main()` function in SICILIAN.py

As you are setting values to the variables in the `main()` frunction in SICILIAN.py, you may notice the variable `star_path`. This should be set to the lcoation of the STAR executable file. Simply use the `wget` command to download the zip file for [STAR](https://github.com/alexdobin/STAR/releases/download/2.7.11b/STAR_2.7.11b.zip) in the target directory. Note that the link provided is the latest release of STAR as of 10/17/24. The value of the `star_path` can then be set to something along the lines of `/project/cphg-millerlab/christine_tsai/01-diff-splice/SICILIAN/STAR/STAR_2.7.11b/Linux_x86_64/STAR` (note the specific subdirectory of the main STAR directory).


#### 2. FASTQ Files for the Input RNA-Seq data
  
Once you have your FASTQ files for the input RNA-seq data, there are some things worth noting that relate again to the variables in the `main()` function of `SICILIAN.py`. The variables relating to the FASTQ input files are the following: `data_path`, `names`, and `r_ends`. The names of the FASTQ files should have the same prefix (e.g. `rca1-1_S1_L001`), but they should have unique suffixes (e.g. `_R1_001.fastq.gz`, `_R2_001.fastq.gz`). Thus, when combining the two components of the file name together, we can arrive at the full file name which is found in `data_path` (e.g. `rca1-1_S1_L001_R1_001.fastq.gz` for the forward read). 

`r_ends` should be set to a *list* of the unique file name endings of the R1 and R2 FASTQ files (i.e. contain the suffixes in square brackets and separate the suffixes using commas).   

`names` should be set to the prefix that all the FASTQ file names have in common. 

Note: if you are interested in creating a "toy directory" to familiarize yourself with the workflow of running SICILIAN and you want to work with a smaller subset of the FASTQ files, you can use the `head` command to take some number of sequences (e.g. `head -n 240 original_file.fastq > toy_file.fastq`). Just make sure that the file you are subsetting is in its proper, uncompressed format (so if you are working with FASTQ files, make sure the target file you are subsetting is NOT a .fastq.gz which is compressed!). 


### Running Your Scripts
Note: the following assumes you are interested in running the default steps of SICILIAN (i.e. run_map to run SYAT alignment, run_class to run the class input job, and run_GML to assign statistical scores to each junction found in the class input file produced by the previous step). Later on, the output of the *second* step, run_class, will be used as an input for SpliZ to quantify the differential expression levels. The reason why there is still value in running the third step, run_GLM, is that the third step's output files can potentially be used as a reference during any post-processing. If you do not wish to adhere to the default steps, you can feel free to set the parameters that toggle which steps to run in SICILIAN.py.

When you execute the SICILIAN.py script by using the command `python SICILIAN.py`, the script should handle making the slurm job scripts for the steps in the SICILIAN process that you set for it to execute by setting the boolean values for the parameters that control which steps are run. To confirm everything has worked properly in generating the slurm job scripts, you can check the 01-scripts directory which should contain the following scripts if you are following the default settings for running steps in SICILIAN: `run_class_input.sh`, `run_GLM.sh`, and `run_map.sh`.

To keep track of the status of each step, you can execute the following command in the terminal: `squeue -u <your-computing-id> -i 3`. As each step of SICLIAN is running, be sure to monitor the .out and .err files found in the 02-outputs/log_files directory.