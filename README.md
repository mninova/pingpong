# pingpong
This script calculates ping-pong signature for reads falling into a certain interval as defined by a bed file. It is hardcoded to select reads of specific length! >24, <33. Not reviewed - use at your own risk.
The input requires a BAM file with aligned reads to the genome, and a bed file with the specific intervals.

