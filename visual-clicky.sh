#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/tools/libfuncs.sh 2>/dev/null

clean () {
  killall -9 click 
  killall -9 clicky
}

trap clean 2

usage () {
  echo -e "\

  ${bold}DESCRIPTION${txtrst}
    Shell script to visualize click experiment using clicky

    ${bold}SYNOPSIS${txtrst}
      ${txtylw}${bold}visual_clicky.sh  -f | --file${txtrst} CLICK_PATH_FILE
                       [${txtylw}${bold}-p | --port${txtrst} PORT]
                       [${txtylw}${bold}-s | --ccss${txtrst} CCSS_FILE]
                       [${txtylw}${bold}-h${txtrst}]"
                
}

unset CLICK_FILE
unset PORT
unset CCSS_FILE

allopt=("$@")

for ((i=0;i<$#;i++)); do
  flag="${allopt[i]}"
  case "${flag}" in
    -f|--file) CLICK_FILE="${allopt[i+1]}"
      i=$((i+1))
      ;;
    -p|--port) PORT="${allopt[i+1]}"
      i=$((i+1))
      ;;
    -h|--help) usage; exit 0;;
    -s|--ccss) CCSS_FILE="${allopt[i+1]}"
      i=$((i+1))
      ;;
    *) echo -e "Option $flag is not processed.\n
                Please use option ${bold}-h${txtrst} to get more information"
      ;;
    esac
done

if [ "$CCSS_FILE" = "" ]; then
  CCSS_FILE=./clicky.ccss
fi

if [ "$PORT" = "" ]; then
  PORT=8001
fi

if [ "$CLICK_FILE" = "" ]; then
  print_error "You have to provide a Click file"
  exit 0
fi

click -p $PORT $CLICK_FILE &
sleep 1
clicky -p $PORT -s $CCSS_FILE 
