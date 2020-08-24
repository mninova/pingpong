# pingpong
The pair_overlap_selected_regions.pl script calculates ping-pong signature for reads falling into a certain interval as defined by a bed file. It is hardcoded to select reads of specific length! >24, <33. Not reviewed - use at your own risk.
The input requires a BAM file with aligned reads to the genome, and a bed file with the specific intervals. See test directory

The pair_overlap_selected_regions_multiply_ONLY.pl does the same, however, it does not normalize such that one read can be counted multiple times for all 5'-5' partnerships it participates in.

