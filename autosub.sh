#!/bin/bash

### Read config
folder=${PWD}/movies/$1
[ ! -d $folder ] && echo "Directory $folder DOES NOT exists." && exit

srclangfile="${folder}/src.txt"
deslangfile="${folder}/des.txt"
[ ! -f $srclangfile ] && echo "File $srclangfile DOES NOT exists." && exit
[ ! -f $deslangfile ] && echo "File $deslangfile DOES NOT exists." && exit
srclang=$(head -n 1 $srclangfile)
deslang=$(head -n 1 $deslangfile)
echo 'source language:'$srclang
echo 'destination language:'$deslang
[ ! -d $folder/$srclang ] && echo "Directory $folder/$srclang DOES NOT exists." && exit
mkdir -p $folder/$deslang

infile="${folder}/in.txt"
outfile="${folder}/out.txt"
[ ! -f $infile ] && echo "File $infile DOES NOT exists." && exit
[ ! -f $outfile ] && echo "File $outfile DOES NOT exists." && exit

donefile="${folder}/done.txt"

### START
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

echo 'done'
