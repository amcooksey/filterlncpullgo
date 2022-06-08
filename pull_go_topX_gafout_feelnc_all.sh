#!/bin/bash
#COMBINE INDIVIDUAL TISSUE GAFS INTO A SINGLE GAF--NEED TO MAKE A LIST OF BTO THEN ENTER THEM | SEPARATED WITH ONLY UNIQ

#REMOVE OLD FILE AND START FRESH WITH EACH RUN
touch feelnc_GO_2.gaf


#CAT ALL THE INDIVIDUAL GAFS TOGETHER
cat *_feelnc_GO_2.gaf > feelnc_GO_2.tmp
sort -k2 -d feelnc_GO_2.tmp > feelncsort_2.tmp

#MAKE AN ARRAY OF ALL UNILNC IDS
lncarray=($(awk '{print $2}' feelncsort_2.tmp | sort | uniq ))
for u in "${lncarray[@]}"
do
	grep $u feelncsort_2.tmp > "$u".tmp

	awk -F '\t' '{print $16}' "$u".tmp |sort|uniq  > "$u"_bto.tmp
	sed -i -z 's/\n/|/g' "$u"_bto.tmp

	cat "$u".tmp | sort -u -k 4,4 > "$u"_2.tmp

	bto=$(cat "$u"_bto.tmp)
	sed 's/\t/%/g' "$u"_2.tmp | while IFS='%' read a b c d e f g h i j k l m n o p q
	do
		echo -e "$a\t$b\t$c\t$d\t$e\t$f\t$g\t$h\t$i\t$j\t$k\t$l\t$m\t$n\t$o\t$bto\t$q" >> feelnc_GO_2.gaf
	done

	rm "$u".tmp  "$u"_2.tmp "$u"_bto.tmp

done

rm *.tmp
