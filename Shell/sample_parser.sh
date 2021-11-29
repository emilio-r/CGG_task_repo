#!/bin/bash

#Script to parse CGG-sample.txt. 
#USE: sh sample_parser.sh -s {infile}

#Enterable options to specify inputfile & tiny helpflag
while getopts "s:m:h" opt; do
  case "${opt}" in
    s) sample=${OPTARG}
    ;;
    h) echo "use flag -s to designate a sample input";
    exit 1
    ;;
    \?) echo "invalid flag";
    exit 1
  esac
done

#Start with a sanitycheck that the input follows correct format
#and check date for logs
A=$(head -1 $sample | cut -d "," -f 6)
B=$(head -1 $sample | cut -d "," -f 1)
D=$(date +%Y-%m-%d)

echo ""
echo -e "Running sample_parser.sh on $D"
echo ""

if [[ $A == "qc_pass" ]] && [[ $B == "sample" ]]; then

  mkdir temp_outs
  #create an indexfile of all samples present in the input
  cat $sample | cut -d "-" -f 1 | sort | uniq | sed '/^sample/d' > temp_outs/IDs.txt
  
  #Separate the output of each sample
  while IFS="," read -r line
  do
    grep -wi "$line" $sample >> temp_outs/$line'_separate.txt'
  done < temp_outs/IDs.txt
  
  #Create an output and add a header
  echo -e "Origin,Nr_of_samples,Nr_of_Failed,Quota,Percentage_failed" > 'Parsed.'$D'.out'
  
  #loop through all the separated outputs and extract the desired info.
  for out in temp_outs/*separate.txt
  do
    ID=$(echo $out | cut -d "/" -f 2 | sed 's/\_separate.txt//g') #name of origin
    l=$(wc -l $out | cut -d " " -f 1 ) #number of samples per origin
    F=$(grep -cw "FALSE" $out) #number of false
    Q=$(awk -v v1=$F -v v2=$l 'BEGIN { print  ( v1 / v2 ) }') #Quota of false
    QP=$(echo $Q | sed 's/\.//g' | cut -c 1-3) #Percentage of false
    #Put this info into a main outputfile
    echo -e "$ID,$l,$F,$Q,$QP%" >> 'Parsed.'$D'.out'
    
    #Do a check on the value and produce a warning if above 10%.
    if [[ $((10#$QP)) -ge 10 ]] ; then
      echo -e "Warning: origin $ID has over 10% failed samples!"
    fi  
  done
  
  #Cleanup temp files
  rm -r temp_outs/
#if input is wrong, just produce this stdout and exit.
else
  echo -e "Your inputfile $sample does not seem correctly formated!"
  exit 1
fi

