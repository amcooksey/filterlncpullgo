#!/bin/bash

while getopts 'a:d:o:t:T:' option
do
  case "${option}" in
    a) assby=${OPTARG};;
    d) database=${OPTARG};;
    o) dbobjtyp=${OPTARG};;
    t) taxon=${OPTARG};;
    T) tissue=${OPTARG};;
    \?) echo "No legal parameters were passed. Please run with -h parameter to see help"; exit 1;;
esac
done

declare -A btoarray
while read -r key value; do
    btoarray[$key]=$value
done < bto.txt

touch "$tissue"_feelnc_GO_2.gaf
sed 's/\t\t/\tempty\t/g' goa_chicken.gaf > goa_chicken.gaf.tmp

#SET EACH RELEVANT FILE AS VARIABLE FOR EASE OF ACCESS
feelncX="lncRNA_classes_UNILNC_top2.txt"
mapping="gga_ens_uni_mapping_15DEC21.csv"
gaf="goa_chicken.gaf"
tmpgaf="goa_chicken.gaf.tmp"
unilncmap="$tissue_lncRNA_mapping.txt"

date=$(date '+%Y%m%d')


cat $feelncX | while IFS=$'\t' read -r unilnc best tringene trinitylnc none ensbtag ensbtat partbiotype dir type distance subtype location
do
	grep $ensbtat $mapping > "$ensbtat".tmp
	if [ ! -s "$ensbtat".tmp ]
	then
		uniprot="none"
		echo -e "$unilnc\t$ensbtat\t$trinitylnc" >> 2_nouni.tmp
		echo -e "$uniprot--NONE--F" >> uniprot_tracking.tmp
        fi
	grep $ensbtat $mapping | while IFS=$',' read -r ensbtag ensbtat biotype swiss trembl
	do
	        if [[ -s "$ensbtat".tmp ]]
	        then
        		touch uniprot_tracking.tmp
                	if [ ! -z "$swiss" ]
                       	then
				uniprot=$swiss
              			echo -e "$uniprot--SWISS--F" >> uniprot_tracking.tmp
                       	elif [[ -z "$swiss"  &&  ! -z "$trembl" ]]
                       	then
				uniprot=$trembl
               			echo -e "$uniprot--TREMBL--F" >> uniprot_tracking.tmp
                       	else
				uniprot="WTF"
                       		echo -e "$uniprot--WTF--F" >> uniprot_tracking.tmp
                       	fi
		        if [[ "$uniprot" != "none" ]]
		        then
		        	grep $uniprot $tmpgaf | sort -rdk 9 > "$uniprot"_fromgaf.tmp
			fi
		        if [[ ! -s "$uniprot"_fromgaf.tmp ]]
		        then
				echo -e "$uniprot\t$ensbtat\t$ensbtag\t$unilnc" >> noGO_2.tmp
		        fi
		        cat "$uniprot"_fromgaf.tmp | while IFS=$'\t' read -r db objid objsym qual goid dbref eco worf aspect objname remainder
               		do
		        	if [[ ! -z $unilnc ]]
               		   	then
					echo -e "$database\t$unilnc\t$unilnc\t\t$goid\t\tIGC\tEnsembl:$ensbtat\t$aspect\t\t\t$dbobjtyp\ttaxon:$taxon\t$date\t$assby\t${btoarray["$tissue"]}\t" >> "$tissue"_feelnc_GO_2.gaf
               		        fi
               		        if [[ $aspect == "P" ]]
               		        then
               			        break
              		 	elif [[ $aspect != "P" ]]
               			then
              			        echo -e "$uniprot\t$ensbtat\t$ensbtag\t$unilnc" >> noBP_2.tmp
               			fi
              		done
                fi
	done
done
cat 2_nouni.tmp | sort | uniq > "$tissue"_targets2_wo_uniprot_feelnc.txt

cat noGO_2.tmp | sort | uniq > "$tissue"_targets2_noGO_feelnc.txt

cat noBP_2.tmp | sort | uniq > "$tissue"_targets2_noBP_feelnc.txt

rm *.tmp

