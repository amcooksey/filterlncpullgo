#!/bin/bash

#PULL TOP 2 INTERACTING TRANSCRIPTS

while getopts 't:' option
do
  case "${option}" in
    t) tissue=${OPTARG};;
    \?) echo "No legal parameters were passed. Please run with -h parameter to see help"; exit 1;;
esac
done



awk '{ print $3 }' "$tissue"_lncRNA_classes.txt | uniq > top.tmp
touch "$tissue"_lncRNA_classes_top2.txt
for k in $(cat top.tmp)
	do
	grep $k  "$tissue"_lncRNA_classes.txt | head -n 2 >> "$tissue"_lncRNA_classes_top2.txt
	done
rm top.tmp

touch "$tissue"_lncRNA_classes_UNILNC_top2.txt
touch "$tissue"_match.txt
cat "$tissue"_lncRNA_classes_top2.txt | while read -r isBest lncRNA_gene lncRNA_transcript lncRNA_biotype partnerRNA_gene partnerRNA_transcript partnerRNA_biotype direction type distance subtype location
do
	tail -n+2 "$tissue"_lncRNA_mapping.txt | while read -r uni xloc gene trans
	do
		if [ $trans = $lncRNA_transcript ]
		then
			echo -e "$uni\t$isBest\t$lncRNA_gene\t$lncRNA_transcript\t$lncRNA_biotype\t$partnerRNA_gene\t$partnerRNA_transcript\t$partnerRNA_biotype\t$direction\t$type\t$distance\t$subtype\t$location" \
			>> "$tissue"_lncRNA_classes_UNILNC_top2.txt
			echo -e "$uni\t$lncRNA_transcript\t$trans\tmatch" >> "$tissue"_match.txt
		else
                        echo -e "$uni\t$lncRNA_transcript\t$trans\tno match" >> "$tissue"_match.txt
		fi
	done
done
