#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/tools/libfuncs.sh 2>/dev/null

clean () {
  return  
}

trap clean 2 EXIT SIGTERM

usage () {
  echo -e "\

  ${bold}DESCRIPTION${txtrst}
    Extend the ability of click file to support multiple included clicks into
    one.

    ${bold}SYNOPSIS${txtrst}
      ${txtylw}${bold}eclick-compile.sh  [-f | --file${txtrst}] CLICK_FILE
                         [${txtylw}${bold}-h | --help${txtrst}]"
                
}
option_config_add "DESCRIPTION" "eclick-compile.sh" "1" "Extend the ability of click file to support multiple included clicks into file"
option_config_add "-f"          "ECLICK_FILE"       "1" "Extended Click file"
#nil-option: _ (no need option)
option_config_add "_"           "ECLICK_FILE"       "1" "Extended Click file"
option_config_add "--file"      "CLICK_FILE"        "1" "Extended Click file"
option_config_add "-h"          "HELP"              "0" "Help information"
option_config_add "--help"      "HELP"              "0" "Help information"
option_config_add "-o"          "OUTPUT"            "1" "Output file (click file). Default is /dev/stdout"
option_config_add "--ouput"     "OUTPUT"            "1" "Output file (click file). Default is /dev/stdout"

option_parse "$@"

if [ "$HELP" == "true" ]; then
  #usage
  option_usage_print
  exit 0
fi

if [ "$ECLICK_FILE" = "" ]; then
  print_error "You have to provide a Click file"
  exit 0
fi

if [ "$OUTPUT" == "" ]; then
  OUTPUT=/dev/stdout
fi

#Set the click include path environment
if [ "$CLICK_INCLUDE_PATH" == "" ]; then
  CLICK_INCLUDE_PATH=.:`dirname $ECLICK_FILE`
else
  CLICK_INCLUDE_PATH=.:`dirname $ECLICK_FILE`:$CLICK_INCLUDE_PATH
fi

#Get included files in ECLICK file
INCLUDED_FILES=`cat $ECLICK_FILE | grep "//#include" | awk '{print $2}'`

#Generate compiled click file
for f in $INCLUDED_FILES; do 
  #find the included click file
  f=`echo $f | sed -e 's/^"//g' -e 's/"$//g'`
  f=`find_file_in_dirset "$f" "$CLICK_INCLUDE_PATH"`
  cat `echo $f | sed -e 's/^"//g' -e 's/"$//g'` >> $OUTPUT
  if [ $? -ne 0 ]; then
    rm -f $OUTPUT
    exit -1
  fi
done

cat $ECLICK_FILE >> $OUTPUT

