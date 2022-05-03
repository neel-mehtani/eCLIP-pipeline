#!/bin/bash

group_num="group$1"

## Navigate to Ocean's project directory with group specific folder
cd $PROJECT/../shared/$group_num

git clone https://github.com/YeoLab/eclip.git
chmod ugo=+rwx eclip/
git clone https://github.com/tbischler/PEAKachu.git
chmod ugo=+rwx PEAKachu/

## Create a data directory
mkdir -m777 data
cd data

## Create sample links text file in the data directory
touch sample-links.txt
echo "Sample, Read1, Read2, Filename1, Filename2">>sample-links.txt
echo "control|https://www.encodeproject.org/files/ENCFF495WQA/@@download/ENCFF495WQA.fastq.gz|https://www.encodeproject.org/files/ENCFF492QZU/@@download/ENCFF492QZU.fastq.gz|ENCFF495WQA.fastq.gz|ENCFF492QZU.fastq.gz">>sample-links.txt
echo 'sample1|https://www.encodeproject.org/files/ENCFF930TLO/@@download/ENCFF930TLO.fastq.gz|https://www.encodeproject.org/files/ENCFF462CMF/@@download/ENCFF462CMF.fastq.gz|ENCFF930TLO.fastq.gz|ENCFF462CMF.fastq.gz'>>sample-links.txt
echo 'sample2|https://www.encodeproject.org/files/ENCFF163QEA/@@download/ENCFF163QEA.fastq.gz|https://www.encodeproject.org/files/ENCFF942TPA/@@download/ENCFF942TPA.fastq.gz|ENCFF163QEA.fastq.gz|ENCFF942TPA.fastq.gz'>>sample-links.txt

## Create subdirectories
mkdir -m777 {K562,ref-seq-ucsc,GenomeDir}

## add reference genome sequence and gene annotations
cd ref-seq-ucsc
wget "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz"
wget "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.refGene.gtf.gz"
gunzip hg38.refGene.gtf.gz
gunzip hg38.fa.gz

cd ../ 

##sample_file="$PROJECT/../shared/$group_num/data/sample-links.txt"
LINES=$(tail -n +2 sample-links.txt | cut -d '|' -f 1-5)
cd K562

for LINE in $LINES
do
    cat $LINE
    touch interim1.txt
    echo $LINE>>interim1.txt
    cat interim1.txt
    list=$(cut -f1 -d "|" interim1.txt)
    mkdir $(echo $list)
    cd $(echo $list)
    touch interim2.txt
    echo $LINE>>interim2.txt
    cat interim2.txt
    awk -F '|' '{print $2}' interim2.txt | xargs wget
    awk -F '|' '{print $3}' interim2.txt | xargs wget
    awk -F '|' '{print $4}' interim2.txt | xargs gunzip
    awk -F '|' '{print $5}' interim2.txt | xargs gunzip
    rm interim2.txt
  	COUNTER=1

	for FILE in *
   	do
     	mv $FILE "read${COUNTER}.fastq"
        ((COUNTER++))
   	done

    cd ../
    rm interim1.txt
done



