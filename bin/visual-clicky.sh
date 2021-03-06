#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
CLICKLABS_HOME=$FILEDIR/..
# Bash shell script library functions
source $FILEDIR/../libs/libfuncs.sh 2>/dev/null

clean () {
#  if [ "$NOCLICKY" == "false" ]; then
    killall -9 click 2>/dev/null
    killall -9 clicky 2>/dev/null
#  fi
  rm -f $ECLICK_FILE 2>/dev/null
}

trap clean 2 EXIT SIGTERM

usage () {
  echo -e "\

  ${bold}DESCRIPTION${txtrst}
    Shell script to visualize click experiment using clicky

    ${bold}SYNOPSIS${txtrst}
      ${txtylw}${bold}visual_clicky.sh  [-f | --file${txtrst}] CLICK_PATH_FILE
                        [${txtylw}${bold}-p | --port${txtrst} PORT]
                        [${txtylw}${bold}-s | --ccss${txtrst} CCSS_FILE]
                        [${txtylw}${bold}-h${txtrst}]"
                
}

option_config_add "-h" "HELP" "0" "Help on visual-clicky"
option_config_add "--help" "HELP" "0" "Help on visual-clicky"
option_config_add "-f" "CLICK_FILE" "1" "Click file"
#nil-option: _ (no need option)
option_config_add "_" "CLICK_FILE" "1" "Click file"
option_config_add "--file" "CLICK_FILE" "1" "Click file"
option_config_add "-p" "PORT" "1" "Port"
option_config_add "--port" "PORT" "1" "Port"
option_config_add "-s" "CCSS_FILE" "1" "CCSS File used to make decoration on clicky"
option_config_add "--ccss" "CCSS_FILE" "1" "CCSS File used to make decoration on clicky"
option_config_add "--noclicky" \
                  "NOCLICKY" \
                  "0" \
                  "Do not use clicky to visualize configuration (only use click to trace something)."

option_parse "$@"

if [ "$HELP" == "true" ]; then
  usage
  exit 0
fi

if [ "$CCSS_FILE" = "" ]; then
  CCSS_FILE=$CLICKLABS_HOME/clicky.ccss
fi

if [ "$PORT" = "" ]; then
  PORT=8001
fi

if [ "$CLICK_FILE" = "" ]; then
  print_error "You have to provide a Click file"
  exit 0
fi

#Support Extended-Click file
ECLICK_FILE=./`date +%s`-`basename $CLICK_FILE`
#Generate normal click file from extended-click file
eclick-compile.sh -f $CLICK_FILE -o $ECLICK_FILE
#Click

if [ "$NOCLICKY" == "true" ]; then
  click -f $ECLICK_FILE  
else
  click --no-warning -R -p $PORT -f $ECLICK_FILE 1>/dev/null & 
  sleep 1
  clicky -p $PORT -s $CCSS_FILE 2>/dev/null 
fi
rm -f $ECLICK_FILE 2>/dev/null
