#!/bin/bash

#folder="${PWD}/movies/giant-2010"
folder=${PWD}/$1
infile="${folder}/in.txt"
outfile="${folder}/out.txt"

srclang=en
deslang=vi

i=0
. ./subtranslate/venv/bin/activate
readarray -t outarr < $outfile
cat $infile | while read line 
do
  echo '['$((i+1))']' $line
  src='"'$folder$srclang/$line'"'
  des='"'$folder$deslang/${outarr[${i}]}'"'
  cmd="python3 ./subtranslate/main.py --src-lang=$srclang --des-lang=$deslang --input-srt=$src --output-srt=$des"
  echo $cmd
  eval $cmd
  i=$((i+1))
done

