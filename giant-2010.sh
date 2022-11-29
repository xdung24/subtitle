#!/bin/bash

folder="${PWD}/movies/giant-2010"
infile="${folder}/in.txt"
echo $folder
outfile="${folder}/out.txt"

srclang=en
deslang=vi

i=0
j=1
. ./subtranslate/venv/bin/activate
readarray -t outarr < $outfile
cat $infile | while read line 
do
  echo '['$j']' $line
  src='"'$folder/$srclang/$line'"'
  des='"'$folder/$deslang/${outarr[${i}]}'"'
  cmd="python3 ./subtranslate/main.py --src-lang=$srclang --des-lang=$deslang --input-srt=$src --output-srt=$des"
  echo $cmd
  #eval $cmd
  i=$((i+1))
  j=$((j+1))
done

