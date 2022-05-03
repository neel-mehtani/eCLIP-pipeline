# eCLIP-pipeline
Automated implementation of eCLIP-seq NGS data processing for downstream peak analysis of RBPs using Bridges - Pittsburgh SuperComputer

## 1. Introduction
### 1.1 About
This pipeline works to integrate various software tools in a streamlined, user-friendly way to investigate RNA-binding protein interactions. The user is able to input a paired-end library type eCLIP dataset, retrievable from the ENCODE website, which gets processed through our pipeline to receive functional information about their RNA-binding protein of interest. This entire workflow is executable through the command line on a high performance computing cluster via a user-friendly batch script, which allows for larger computing allocations to be done easily if necessary. We have detailed code shown in the ‘Running the Pipeline’ section to show what is done comprehensively. We recommend using a computing server, such as BRIDGES-2, to be able to achieve all computational requirements. Here we introduce an efficient pipeline that works to find potential conserved motifs of any RNA-binding protein.


## 2. Packages/Data
Listed are the packages and input files required to implement the pipeline. Furthermore, links are listed for more information about each particular tool.


### 2.1 Fastq Data
Usable input data can be found on the ENCODE  website by looking for the ENCORE eCLIP data repository and navigating to ‘File Details for a specific dataset’, which will show replicates of raw sequencing data in a fastq file type for controls and experimental samples. An example is listed below for the RNA-binding protein, RBFOX2 for the K562 experimental cell line. All data inputted into the pipeline must be paired-end library type and are labeled as PE. Many proteins will have multiple biological replicates that should be used. Additionally, under ‘Summary’ details, information about control eCLIP experiments are linked, which will be utilized for ensuring experimental conditions are met. An example of the control for RBFOX2 is listed below.   

RBFOX2 example: https://www.encodeproject.org/files/ENCFF930TLO/
RBFOX2 control: https://www.encodeproject.org/files/ENCFF495WQA/

The specific samples of interest will be stored in a separate file called “sample-links.txt” with their corresponding url links and name of the files retrieved from that link when called using a wget command in the setup (as shown below).

*** insert image here ***

During the automated setup processing, the files for reads 1 and 2 are renamed as read1.fastq and read2.fastq for all control/experimental sample reads. This helps in generalizing the pipeline workflow.


### 2.2 Cutadapt
Adapters are necessary for PCR amplification and sequencing. However, adapters may be sequenced  if the machine goes past the read. As such, Cutadapt is a tool to trim adapters and adapter-dimers and will remove adapters from both the 3’ and 5’ end of sequenced reads. 

For more information about cutadapt:
https://cutadapt.readthedocs.io/en/stable/guide.html#basic-usage


### 2.3 Fastqc
Fastqc is a tool to assess the quality of the raw data for high throughput sequence data. This ensures that the data is pre-processed correctly such that alignment to a reference genome can occur smoothly.

For more information about Fastqc and installation:
https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

### 2.4 STAR
STAR is an alignment tool that does 2 main methods:
generate genome index files from user-supplied reference genome sequences (FASTA file type) and annotation files (gtf file type) 
Map reads to the genome file

For more information about STAR: https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf
To create the STAR environment:
https://github.com/alexdobin/STAR

### 2.5 UMI-tools
UMI-tools is a package designed to deal with Unique Molecular Identifiers (UMIs) that are present in high sequencing experiments. Through a UMI, identical copies arising from distinct molecules can be distinguished from those arising through PCR amplification of the same molecule. As such UMI-tools helps to ensure we have unique reads for peak calling. 

For more information about UMI-tools:
https://genome.cshlp.org/content/27/3/491
For information on downloading UMI-tools:
https://github.com/CGATOxford/UMI-tools

### 2.6 Samtools
Samtools is a set of operations that can manipulate alignments in SAM and BAM-formatted files. Its tools include format conversions, sorting, merging, indexing, and retrieving reads in any regions swiftly.

For more information on Samtools:
http://www.htslib.org/doc/samtools.html


### 2.7 PEAKachu
PEAKachu is a peak-calling tool specifically for CLIP and eCLIP data, which will find possible binding motifs. Unlike other peak calling tools, PEAKachu is able to incorporate control data, which allows us to identify significant binding regions. 

For more information on PEAKachu/downloading PEAKachu:
https://github.com/tbischler/PEAKachu


## 3. Packaging Installation on Bridges-2
Module is the command for software package management
• module avail: shows all installed software packages 
• module load: loads a specific package
• module list: shows currently loaded software packages 
• module help: help information for a software package 

The Bridges modules used in this pipeline include: AI/anaconda3-tf1.2020.11, STAR/2.7.6a, and cutadapt/2.10.

For more information on package installation onto Bridges-2:
https://www.psc.edu/resources/bridges-2/user-guide-2-2/


## 4. Launching Pipeline on Bridges-2
Bridges-2 is a supercomputer that provides powerful general-purpose computing, computation intensive analysis, and pre- and post-processing. Considering this pipeline is designed for eCLIP data, running this on a supercomputer is highly recommended for computational and memory allocation resources. 

Our pipeline can be installed in the Bridges environment by cloning its git repository (https://github.com/sriskid/group1-bdip.git) after logging into Bridges-2 with your XSEDE credentials on port 2222. Launching the pipeline is based on the assumption that the user has XSEDE credentials and also has a /group_num directory in the $PROJECT/../shared/ workspace, corresponding to your group number. Further, it requires two prerequisites after which the pipeline will be ready to launch. These steps can be accomplished in the following fashion:

Prerequiste 1: Cloning git repo and automating workspace setup
$ cd $HOME
$ git clone https://github.com/sriskid/group1-bdip.git
$ bash ./group1-bdip/setup_script.sh <YOUR-GROUP-NUM>

Prerequiste 2: Creating Conda environments
$ module load AI/anaconda3-tf1.2020.11
$ conda config --add channels bioconda

$ conda create -y --name preprocess1   
$ conda activate preprocess1
$ conda install -y -c bioconda fastq-tools
$ conda install -y -c biconda samtools=1.6
$ conda deactivate

$ conda create -y –name preprocess2 python=2.7.17
$ conda activate preprocess2
$ conda install -y -c bioconda pysam
$ conda install -y -c bioconda samtools=1.6
$ conda deactivate
  
### 5. Running the Pipeline
Here we lay out the detailed outline of how this pipeline is run. However, the code snippets shown here are put in separate scripts that are then called on by a batch script the user runs. This ensures a more efficient, user-friendly approach to using our pipeline. 

The core of our pipeline implementation can be executed in a modular-step wise fashion from top-to-bottom using the following commands to accomplish the following tasks:

Preprocessing - Part 1: 
$ conda activate preprocess1
$ sbatch -p RM-shared -t 8:00:00 -n 12 —ntasks-per-node=64 ./group1-bdip/preprocess1.run <YOUR-GROUP-NUM>
$ conda deactivate

Preprocessing - Part 2:
$ conda activate preprocess2
$ sbatch -p RM-shared -t 8:00:00 -n 12 —ntasks-per-node=64 ./group1-bdip/preprocess2.run <YOUR-GROUP-NUM>
$ conda deactivate
  
Peak Analysis: 
$ sbatch -p RM-shared -t 8:00:00 -n 12 —ntasks-per-node=64 ./group1-bdip/peak_call.run <YOUR-GROUP-NUM>

Note: “--ntasks-per-node” is prefixed by two “-”

### 6. Limitations
It must be noted that biological sequencing data requires large amounts of storage capacity, which makes it difficult for most parts of this pipeline to be implemented on a local machine. Given the capacity of this pipeline to be utilized for multiple eCLIP datasets, there is a need for a large computational requirement. As such, we highly recommend using a supercomputer cluster, such as BRIDGES-2, to carry out all parts of the pipeline for a streamlined approach. Furthermore, the appropriate number of threads can be optimized to ensure maximum efficiency when carrying out heavy computing operations, such as the genome alignment step. 


  







