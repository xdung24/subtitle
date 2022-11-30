#!/bin/bash

#folder="${PWD}/movies/giant-2010"
folder=${PWD}/$1
infile="${folder}/in.txt"
outfile="${folder}/out.txt"
donefile="${folder}/done.txt"

srclang=en
deslang=vi

i=0
source ${PWD}/subtranslate/venv/bin/activate
readarray -t outarr < $outfile
cat $infile | while read line 
do
  echo '['$((i+1))']' $line
  name=${outarr[${i}]}
  src='"'$folder/$srclang/$line'"'
  des='"'$folder/$deslang/${name}'"'
  cmd="python3 ./subtranslate/main.py --src-lang=$srclang --des-lang=$deslang --input-srt=$src --output-srt=$des"
  if grep -Fx "$name" $donefile
  then
    echo 'already done, skip'
  else
    echo $cmd
    eval $cmd
    echo $name>>$donefile
  fi
  i=$((i+1))
done

