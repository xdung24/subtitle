#!/bin/bash

folder="${PWD}/subtitle/Giant"
infile="${folder}/in.txt"
echo $folder
outfile="${folder}/out.txt"

srclang=en
deslang=vi

i=0
j=1
. /home/nuc/Documents/subtranslate/venv/bin/activate
readarray -t outarr < $outfile
cat $infile | while read line 
do
  echo '['$j']' $line
  src='"'$folder/$srclang/$line'"'
  des='"'$folder/$deslang/${outarr[${i}]}'"'
  echo $src
  echo $des
  cmd="python3 /home/nuc/Documents/subtranslate/main.py --src-lang=$srclang --des-lang=$deslang --input-srt=$src --output-srt=$des"
  echo $cmd
  eval $cmd
  i=$((i+1))
  j=$((j+1))
done

