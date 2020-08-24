#!/usr/bin/perl/
use warnings;
use strict;

#ATTENTION: This version of the script will not normalize to total number of partners!

#usage perl script.pl mapped_reads.bam region.bed (bed file with regions of interest to be pre-selected)

my $file=shift; #bam file with mapped reads
my $region=shift; #file with given regions

system "bedtools intersect -abam $file -b $region |samtools view - > $file.pis.tmp.ubam";



open (FILE, "$file.pis.tmp.ubam");

open (NEG, ">$file.neg1.tmpbed");
open (POS, ">$file.pos1.tmpbed");



my %positive=();
my %negative=();


while (<FILE>) {

    my (@tmp) = split (/\t/,$_);
    my $strand=$tmp[1];
    my $chrom=$tmp[2];
    my $seq=$tmp[9];
    my $start=$tmp[3];
    my $end=$start+length($seq);
    if ($strand==0) {if ((length($seq)>24) and (length($seq)<33)) {$positive{"$chrom\t$start\t$end\t$seq"}+=1}}

    elsif ($strand==16) {if ((length($seq)>24) and (length($seq)<33)) {$negative{"$chrom\t$start\t$end\t$seq"}+=1}}

}


foreach (sort (keys %positive)) {print POS "$_\;$positive{$_}\n" }
foreach (sort (keys %negative)) {print NEG "$_\;$negative{$_}\n" }
close FILE;
close POS;
close NEG;

system "bedtools intersect -a $file.pos1.tmpbed -b $file.neg1.tmpbed -wo > $file.inters1.tmptab";

my %overlaps=();
my %counts=();
my %totals=();
my %counts10=();
open (TAB, "$file.inters1.tmptab");

while (<TAB>) {
    chomp($_);
    my (@tmp) = split (/\t/,$_);
    my $name1=join(":",$tmp[0],$tmp[1],$tmp[2],$tmp[3]);
    my $name2=join(":",$tmp[4],$tmp[5],$tmp[6],$tmp[7]);
    my $start1=$tmp[1];
    my $start2=$tmp[5];
    my $overlap=$tmp[8];
    if ($start1>$start2) {
	my ($else1,$count1)=split(/\;/,$name1,2);
	my ($else2,$count2)=split(/\;/,$name2,2);

	push(@{$overlaps{$name1}}, $overlap);
	push(@{$counts{$name1}}, $count2);
	$totals{$name1}+=$count2;
	if ($overlap==10) {$counts10{$name1}=1; $counts10{$name2}=1};
    }
}
close TAB;

my %freqs=();

foreach (sort (keys %totals)) 
{#print "$_\t$totals{$_}\t";
    my ($else1,$count1)=split(/\;/,$_,2);
    if (@{$counts{$_}} != @{$overlaps{$_}}) {print "something went wrong" and die}
    for (my $i=0;$i<@{$counts{$_}} ;$i++) {
       $freqs{$overlaps{$_}[$i]}+=$counts{$_}[$i]*$count1;
    }
   # foreach my $m(@{$counts{$_}}) {print "$m:";}
   # print "\t";
   # foreach my $n(@{$overlaps{$_}}) {print "$n:";  }
   # print "\t";
   # print "\n";
}


foreach (sort {$a<=>$b} (keys %freqs)) {print "$_\t$freqs{$_}\n"}

my $tot10=0;
foreach (keys %counts10) {my ($name,$n) = split (/\;/,$_) ; $tot10+=$n}
print STDERR $tot10,"\n";

unlink ("$file.pis.tmp.ubam");
unlink ("$file.pos1.tmpbed");
unlink ("$file.neg1.tmpbed");
unlink ("$file.inters1.tmptab");
unlink ("$file.inters2.tmptab");
