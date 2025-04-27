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

If you encounter any issues with the R libraries that are used in the later steps of SICILIAN after STAR runs, it is possible that you might have to edit the `GLM_script_light.R` script by specifying *where* you want all the libraries to be installed. Since the HPC's migration to R 4.4, there have been frequent issues with libraries not being found -- possibly because it is looking/installing libraries in the wrong directory (4.3). 

As an example, for the `cutpointr` library, I added the path to where I want the library to be installed by providing a value for the `lib` parameter. I would imagine that the location where you want to install the libraries would look quite similar to my path, just replacing my computing id (rtg7bs) with your own computing id. 

`if (!require("cutpointr")) {`
  `install.packages("cutpointr", dependencies = TRUE, lib="/sfs/gpfs/tardis/home/rtg7bs/R/goolf/4.4")`
  `library(cutpointr)}`

Steps to Check R Libraries via Command Line
1. `cd /home/rtg7bs/R/goolf/4.4`, but replace my computing id with your computing id.  
3. `ls` to check libraries installed in that directory 

Other Tips When Facing R Dependency Issues
1. `module load goolf R`
2. `R` to launch R in the command line
3. You can try installing and loading libraries within the command line. Use `q()` to quit


# Using SpliZ to Quantify the Extent of Differential Splicing
## Description
[SpliZ](https://github.com/juliaolivieri/SpliZ_pipeline?tab=readme-ov-file) generates a "splicing Z score" for each gene-cell pair, and it can work directly with the class input file created as an output by SICILIAN.

## Getting Started
Installation and setup consists of the following steps:

1. Clone the SpliZ repo

    `git clone https://github.com/juliaolivieri/SpliZ_pipeline.git`
2. `cd` into the directory for the newly cloned repo, and create a conda environment. The repo includes a file named `environment.yml` which outlines the dependencies for you already. 

    `conda env create --name spliz_env --file=environment.yml`
    Note: I have experienced this step to take longer than expected, especialling during the "Solving environment" step as the environment is being created. Additionally, including the package version numbers was problematic, so if you are unsuccessful in running the `conda env create` command, locate the `environment.yml` file and delete all of the version numbers from the packages listed under "dependencies".

3. Activate the environment
    `source activate spliz_env`

## Running the Pipeline

# SICILIAN Nextflow Pipeline
This serves as a guide for running the SICILIAN pipeline through Nextflow which is recommended for 10x datasets.
NOTE: this tool is depreciated, but I will keep the documentation to show what I have tried. Some links that the documentation suggests you to go to or provide as arguments to nextflow are broken. 

## Getting Started
### Dependencies
The installation of Nexflow requires the following:
- Bash 3.2 or later
- Java 17 or later (use `java -version` to confirm installation)
  
1. Install Nextflow using Bioconda:
    1. `conda config --add channels bioconda`
    2. `conda config --add channels conda-forge`
    3. `conda create --name env_nf nextflow`
    4. `conda activate env_nf` to activate the environment

Resource to refer to if the above instructions do not work: [Nextflow documenttion](https://www.nextflow.io/docs/latest/install.html)

2. Install Docker OR use your available containerization software
    1. `cat /etc/os-release` to check OS distribution
       Example: `NAME="Rocky Linux" VERSION="8.9 (Green Obsidian)"` indicates I am running a Red Hat Enterprise Linux (RHEL). I would then follow the Docker installation process for RHEL.
       Note: using Docker on Rivanna is not supported since installing Docker requires sudo privileges.

Order of Commands I've tried to run Nextflow SICILIAN:

`module load apptainer`

`module load nextflow`

`nextflow run salzmanlab/nf-sicilian -profile test -r dev`

Executing the last command ultimately did not lead to the tool being downloaded and instead led to a dead end.

# List of Other Tools I Have Explored
- scASfind
- UMI-tools
- STARsolo
- ELLIPSIS -- this tool looks the most promising, but I haven't tried inputting my own data since it requires some preprocessing (i.e., getting gene level counts for each cell and a list of neighboring cells for each cell). However, I did successfully run their toy dataset using their tool. I believe that for getting gene level counts for each cell, I would need to use STARsolo to align the data and start from scratch with the Alsaigh et al. data since STARsolo seems to be designed specifically for sc-RNA seq data, and in their manual, they mention the 10x Genomics Chromium System which is mentioned in the extraction protocol for the [Alsaigh et al. data](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM4837524). 

   

