#!/bin/bash

# FIXME: be more general !

##
# Init variables
###########################################
root_dir="$HOME/work/expes/saarbrucken-2015/variability-tts-part"
expes="baseline with_surprisal only_surprisal"
output_dir="tree"
states="2 3 4 5 6"
corpora="full" # validation test"
kinds="mgc lf0"

##
# Stages
###########################################
tree_stat=1      # Generate the statistics of decision tree
cat_report=1     # Generate the plot files for category analysis
node_report=0    # Generate the plot files for node analysis

##
# Generate tree statistics
###########################################
if [ $tree_stat -eq 1 ]
then
    for e in $expes
    do
        for c in $corpora
        do
            cur_output_dir="$output_dir/$e/$c/"
            mkdir -p $cur_output_dir/
            cat $root_dir/$e/input/$c/*.lab | \
                sed 's/[ \t]*[0-9]\+[ \t]*[0-9]\+[ \t]*//' >  "$cur_output_dir/labels"

	        # cout nb_models by labels
            cat $root_dir/$e/input/$c/*.lab | sed 's/[ \t]*[0-9]\+[ \t]*[0-9]\+[ \t]*//' | sort | uniq -c | sort -rn | \
                sed 's/[ \t]*\([0-9]\+\)[ \t]*\(.*\)/\2\t\1/' > "$cur_output_dir/labels_count.csv"


            for k in $kinds
            do
                echo $cur_output_dir/$k
                mkdir -p $cur_output_dir/$k


                for s in $states
                do
                    echo "$cur_output_dir/$k/$s"
                    mkdir -p "$cur_output_dir/$k/$s"

                    # Get pathes (FIXME: be more general than this stuff : $root_dir/$e/trees/qst1/ver1/cmp/$k.inf)
                    perl get_path.pl -s $s \
                         $root_dir/$e/build/raw/trees/$k.inf\
                         "$cur_output_dir/labels" > $cur_output_dir/$k/$s/path_list

				    # Count using pathes
    	            cat $cur_output_dir/$k/$s/path_list | sed 's/.* : //g' | \
                        sort | uniq -c | sort -rn | \
                        sed 's/[ \t]*\([0-9]\+\) \(.*\)/\2;\1/' > "$cur_output_dir/$k/$s/path_count.csv"

				    # Count using nodes
            	    cat $cur_output_dir/$k/$s/path_list | sed 's/.* : //g' | \
                        sed 's/NULL//g' | sed 's/ => /\n/g' | sed 's/[!()]//g' | \
                        sed '/^$/d' | sort | uniq -c | sort -rn | \
                        sed 's/[ \t]*\([0-9]\+\) \(.*\)/\2;\1/' > "$cur_output_dir/$k/$s/node_count.csv"

                    # Count by categorie
                    perl  apply_cat.pl \
                          "$cur_output_dir/$k/$s/node_count.csv" | \
                        sort -k 2 -t';' -rn > "$cur_output_dir/$k/$s/cat_count.csv"
                done
            done
        done
    done
fi

##
# Generate category reports
###########################################
if [ $cat_report -eq 1 ]
then
    rm -rf $output_dir/categories
    mkdir -p $output_dir/categories/

    for corpora in $corpora
    do
        for kind in $kinds
        do
            for state in $states
            do
                echo "$output_dir/categories/${corpora}_${kind}_${state}....."

	            # Merge category statistics
                perl merge.pl "p1;p3;p5;syl_position;syl_prosody;syl_surp;word_position;word_prosody;synt_position;synt_prosody;utt" "$output_dir/%s/$corpora/$kind/$state/cat_count.csv" "baseline" "with_surprisal" "only_surprisal" > $output_dir/categories/${corpora}_${kind}_${state}.csv

                mkdir -p $output_dir/categories/${corpora}/${kind}/${state}/
                Rscript plot.r $output_dir/categories/${corpora}_${kind}_${state}.csv $output_dir/categories/${corpora}/${kind}/${state}/
            done
        done
    done
fi


##
# Generate category reports
###########################################
if [ $node_report -eq 1 ]
then
    rm -rf $output_dir/nodes
    mkdir -p $output_dir/nodes/

    for corpus in $corpora
    do
        for kind in $kinds
        do
            for state in $states
            do
                echo "$output_dir/nodes/${corpus}_${kind}_${state}....."

	            # Merge category statistics
                for e in $expes
                do
                    awk "{printf \"%s;%s\n\", \"$e\", \$0}"   $output_dir/$e/$corpus/$kind/$state/node_count.csv
                done |sort -k1,2 > $output_dir/nodes/${corpus}_${kind}_${state}.csv
            done
        done
    done
fi
