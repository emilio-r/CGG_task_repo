#!/bin/bash

#script will add the running of your parser each week

while getopts "s:m:h" opt; do
  case "${opt}" in
    s) sample=${OPTARG}
    ;;
    m) email=${OPTARG}
    ;;
    h) echo "use flag -s to designate a sample input (absolute path) and -m to designate your email"
    ;;
    \?) echo "invalid flag"
  esac
done

S=$(echo $sample | wc -m)
M=$(echo $email | grep -q @ && echo TRUE)

if [[ $S -gt 1 ]] && [[ $M == TRUE ]]; then
  crontab -l > mycron
  echo "" >> mycron
  echo -e "MAILTO=$email" >> mycron
  echo ""
  echo -e "00 12 * * fri python3 ${PWD}/P_sample_parser.py -s $sample" >> mycron
  echo "" >> mycron
  crontab mycron
  rm mycron
  echo "sample_parser.sh now added to crontab"
else
  echo -e "No sample or email designated"
  echo -e "Use -m to designate email and -s to designate input"
  exit 1
fi
