 #!/bin/bash
#THIS SCRIPT TAKES THE UNILNC IDS FROM GFFCOMPARE AND MAKES A TABULAR MAPPING FILE FOR ALL TISSUES TO CORRELATE NEW ID WITH ORIGINAL ID.

#################################################################################################################################################

tracking="unified_lncrna_ids.tracking"

while getopts 't:' option
do
  case "${option}" in
    t) tissue=${OPTARG};;
    \?) echo "No legal parameters were passed. Please run with -h parameter to see help"; exit 1;;
esac
done

grep 'Summary' unified_lncrna_ids.stats > stattmp.txt
sed -i 's/\#\= Summary for dataset\: //' stattmp.txt
sed -i 's/_candidate_lncRNA.gtf.lncRNA.gtf//' stattmp.txt
sed -i 's/^[ \t]*//;s/[ \t]*$//' stattmp.txt

readarray -t tissuearray < stattmp.txt

rm stattmp.txt

for i in "${!tissuearray[@]}";
do
    if [[ "${tissuearray[$i]}" = "${tissue}" ]];
    then
        index=$i
        break
    fi
done

touch "$tissue"_lncRNA_mapping.txt "$tissue"_temp.txt
query=$(( 1 + $index ))
column=$(( $index + 5 ))
grep q"$query" unified_lncrna_ids.tracking | cut -f 1,2,$column > "$tissue"_temp.txt
sed -i 's/q[0-9]://g' "$tissue"_temp.txt
cat "$tissue"_temp.txt | while read -r unilnc xloc id remainder
do
       	gene=$(echo $id | cut -f3 | cut -d '|' -f1)
       	lnc=$(echo $id | cut -f3 | cut -d '|' -f2)
	if [[ "$gene" != "-" ]]
		then
		        echo -e "$unilnc\t$xloc\t$gene\t$lnc" >> "$tissue"_lncRNA_mapping.txt
	fi
done
rm "$tissue"_temp.txt
