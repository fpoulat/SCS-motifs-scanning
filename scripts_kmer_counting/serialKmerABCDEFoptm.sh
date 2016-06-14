#!/bin/bash

# serialKmer.sh 
# this scripts first reads gellyroll files in the gellyroll_file folder (indir)
# it first uses sed to substitite/transcode sites into letters
# notice that sed needs a file named sedsitecoding that contains the sed
# substitution commands to translate site/matrix names into letters
# example :
# s/ //g
# s/SOX9_D/E/g
# s/SOX9_R/F/g
# s/GATA4_D/C/g
# s/GATA4_R/D/g
# s/DMRT1_D/A/g
# s/DMRT1_R/B/g
#
# allowed codes are A,B,C,D,E,F
# the first part generates fake fasta files suitable for 
# further treament with countKmer.pl to count k-mers of various sizes
# from $1 = min_kmer_size,to $2 = max_kmer_size
# countKmer.pl reads a fasta file containing multiple Sites sequences
# counts k-mers of given length and dumps them into a file


# usage
# open a console
# cd in directory containing this script and a directory named 
# StrandAwareSites_files, that contains the gellyroll files
# then call the script with 2 numeric arguments  
# ./serialKmer.sh min_kmer_size max_kmer_size

# use 6 letters alphabet for coding 3 sites with 2 orientations
sedcoding="../sedsiteABCDEFcoding"
seddecoding="../sedsiteABCDEFdecoding"
kmercounter="../countKmerABCDEF.pl"
alphabet=ABCDEF

# 3 letters for 3 sites without taking orientation into account
#sedcoding="../sedsiteABCcoding"
#seddecoding="../sedsiteABCdecoding"
#kmercounter="../countKmerABC.pl"
#alphabet=ABC

hitparade=1000

echo "strarted script :" $0

# First encode sites into a single lettre code
echo "***** First encode sites into a single lettre code *****"
indir=StrandAwareSites_files		        # directory of input gellyroll files
outdir=../StrandAwareSites_files_FastaFake	# directory to store results of sed transcoding
# jump in file direcory
cd $indir					# so that filenames dont need path
echo "entering :" $indir
# cleanup previous attempts
rm $outdir/*
rmdir $outdir
mkdir $outdir	# create output directory
# now recode sites in each file of directory
for sed_infile in *;		# for each gellyrol file in directory
do
  echo "*** Encoding sites from :"$sed_infile
  outfile=$outdir/$sed_infile"_.Gelly4FastaFake"	# create output file name
  rm $outfile									    # cleanup previous
  echo "** Creating :"$outfile
  sed -f $sedcoding $sed_infile > $outfile # now sed does the job
  # the text file sedcoding contains sed commands 
done

# now jump to the encoded sites files directory to perfrom K-mer countings
echo "***** Now jump to the encoded sites files directory to perfrom K-mer countings *****"
cd $outdir
echo "entering :" $outdir
# create output directory for K-mer counts
gfoutdir=../gfcounts"TOP"$hitparade
mkdir $gfoutdir

# now scan each file for kmer counting
for gf_infile in *;
do

	echo "*** Counting K-mers in file : "$gf_infile
    # create file name
	dumpfile=$gfoutdir/$gf_infile"_"$alphabet"_kmer_dump_"$1"_upto_"$2"_mers_TOP"$hitparade
    # clean previous	
    rm $dumpfile
    # Now count K-mers in the specified range
    #!! warining : above 9 is CPU greedy
	for ((k = $1; k <= $2; k += 1))
	do
		echo "Counting kmers of length : "$k
        perl $kmercounter -k $k -m $gf_infile
		echo "sorting top "$hitparade" kmers by counts"
        echo "***"$k >> $dumpfile
		sort -g -r $gf_infile.counts | head -n $hitparade >> $dumpfile
	done

	echo "kmer counts dumped in file : "$dumpfile

	rm $gf_infile.counts
	echo "done "$gf_infile
done


cd $gfoutdir
echo "entering :" $gfoutdir
decoutdir=../gfcountsdecoded"TOP"$hitparade
mkdir $decoutdir

for sed_infile in *;		# for each gellyrol file in directory
do
  echo "treating :"$sed_infile
  outfile=$decoutdir/$sed_infile".kmerSitesCounts"	# output file name
  rm $outfile									    # cleanup previous
  echo "creating :"$outfile
  sed -f $seddecoding $sed_infile > $outfile # now sed does the job
  # the text file seddecoding contains sed commands 
done
