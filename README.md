# eCLIP-pipeline
Automated implementation of eCLIP-seq NGS data processing for downstream peak analysis of RBPs using Bridges - Pittsburgh SuperComputer

## Introduction
### About
This pipeline works to integrate various software tools in a streamlined, user-friendly way to investigate RNA-binding protein interactions. The user is able to input a paired-end library type eCLIP dataset, retrievable from the ENCODE website, which gets processed through our pipeline to receive functional information about their RNA-binding protein of interest. This entire workflow is executable through the command line on a high performance computing cluster via a user-friendly batch script, which allows for larger computing allocations to be done easily if necessary. We have detailed code shown in the ‘Running the Pipeline’ section to show what is done comprehensively. We recommend using a computing server, such as BRIDGES-2, to be able to achieve all computational requirements. Here we introduce an efficient pipeline that works to find potential conserved motifs of any RNA-binding protein.
