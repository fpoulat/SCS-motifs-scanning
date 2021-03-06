# SCS-motifs-scanning

In this repository you will find the software that was created to investigate the properties of SCS motifs.

---------------------------------------------------------------------------------------------------------------------
MatSig7_x64 : contains the MatSig program

Reads 2 matched ft files (ChIP and Scramble) and counts the occurences of transcription factor sites in each fragment.
It creates a csv file prefixed with Counts_ and a logfile.

In this folder you find the Lazarus source code :

backup  
lib  
MatSig.ico  
MatSig.lpi  
MatSig.lpr  
MatSig.res  
matsigunit1.lfm  
matsigunit1.pas

A Linux64bits executable (tested with ubuntu 14.04)

MatSig

And a directory with test data

test-data

---------------------------------------------------------------------------------------------------------------------------

intervalles_7b_x64 : Contains the mintervals program
mintervals reads a .ft file and allows to create several outpout files :
- filename_oriented_intervalls.csv : all interdistances between transcription factor sites
- filename_Gellyrol : a text file that contains the ordered lists of transcripion factor sites found in each fragment 
- filename_sorted.csv : same structure as a .ft file with sites reordered by position along the fragment

In this folder you find the Lazarus source code :

backup  
IntegerList.pas
lib  
mintervals.ico  
mintervals.lpi  
mintervals.lpr  
mintervals.res  
TIntegerListClass.pas
unit1.lfm
unit1.pas

A Linux64bits executable (tested with ubuntu 14.04)

mintervals

And a directory with test data

test-data

----------------------------------------------------------------------------------------------------------------------------
scripts_kmer_counting

In this directory you find the scripts we used for counting k-mers of transcription factor sites

serialKmerABCDEFoptm.sh :
usage
open a console
cd in directory containing this script and a directory named 
StrandAwareSites_files, that contains the gellyroll files
then call the script with 2 numeric arguments  
./serialKmer.sh min_kmer_size max_kmer_size


This is the bash script file that performs the k-mer counting job.
it reads all the gellyroll files (that you produce with mintervals) found in StrandAwareSites_files folder,
and encodes the sites in a 6 letter abcde alphabet, producing files with extension _.Gelly4FastaFake.
It creates a StrandAwareSites_files_FastaFake folder ans saves the fastafake files in it
For doing the encoding, it uses the GNU sed and the file sedsiteABCDEFcoding.
It then invoques the perl script : countKmerABCDEF.pl
countKmerABCDEF.pl takes the series of fastafake files and counts all the occurrences of all the
possible kmers in each file, then creates an output file with extension _ABCDEF_kmer_dump_4_upto_5_mers_TOP1000.
These filee are then stored in the gfcountsTOP1000 directory.
serialKmer then decodes the ABCDEF 6 letter alphabet back to the oriented transcription factor sites using
GNU sed and the file sedsiteABCDEFdecoding. 
The resulting decoded files are stored in gfcountsdecodedTOP1000. They carry the extension .kmerSitesCounts

3letters            
ft_files                


----------------------------------------------------------------------------------------------------------------------------
KmerHunt : contains the kmerhunter program.

This program reads :
- a kmer counting files as produced by countKmerABCDEF  _ABCDEF_kmer_dump_4_upto_8_mers_TOP1000
- the corresponding Gellyroll file as produced by mintervals
And it reports for each kmer of a chosen size, the list of fragments that contain this kmer.
It produces a file with extension Kerhuntlength8.csv

In this folder you find the Lazarus source code :
lib      
backup       
kmerhunter.ico  
kmerhunter.lpr  
kmerhunter.res        
kmerhunterwindow.pas
kmerhunter.lpi  
kmerhunter.lps  
kmerhunterwindow.lfm

A Linux64bits executable (tested with ubuntu 14.04)

kmerhunter2  




----------------------------------------------------------------------------------------------------------------------------
commonkmers : contains the program komonkmer2
komonkmer2 reads the following files :
- Liste_genes_bostau6_orthologu_mouse_mm10.txt : this is a tex files with 2 columns that lists the names of orthologous genes in two species, here bostau6 and mm10.
- the Kmerhunt lengthX for species 1
- the Kmerhunt lengthX for species 2
It produces then a csv file with a name of the form shared_kmers8_Bostau6_mm10.csv

In this folder you find the Lazarus source code :

backup
komonkmer2.ico
komonkmer2.lpr
komonkmer2.res
unit1.lfm
komonkmer2  
komonkmer2.lpi  
komonkmer2.lps  lib             
test-data                       
unit1.pas

---------------------------------------------------------------------------------------------------------------------------
Instructions for compiling the Lazarus source code
you can get the lazarus IDE and FPC compiler here :
http://www.lazarus-ide.org/

Lazarus is a Delphi compatible cross-platform IDE for Free Pascal. It includes LCL which is more or less compatible with Delphi's VCL. Free Pascal is a GPL'ed compiler that runs on Linux, Win32, OS/2, 68K and more. Free Pascal is designed to be able to understand and compile Delphi syntax, which is OOP. Lazarus is the part of the missing puzzle that will allow you to develop Delphi like programs in all of the above platforms. Unlike Java which strives to be a write once run anywhere, Lazarus and Free Pascal strives for write once compile anywhere. Since the exact same compiler is available on all of the above platforms it means you don't need to do any recoding to produce identical products for different platforms.

---------------------------------------------------------------------------------------------------------------------------
-end-
