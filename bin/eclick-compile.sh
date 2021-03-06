#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/../libs/libfuncs.sh 2>/dev/null

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

#Build included file list
INCLUDED_FILES=""
build_included_list () {
  local f=""
  local ff=""
  local head_file=$1
  local new_included=`cat $head_file | grep "//#include" | awk '{print $2}'`
  
  #stop condition of recursive building included list
  if [ "$new_included" == "" ]; then
    return 
  fi
  
  for f in $new_included; do  
    #remove " in file name
    f=`echo $f | sed -e 's/^"//g' -e 's/"$//g'`
    #find full path of include file
    ff=`find_file_in_dirset "$f" "$CLICK_INCLUDE_PATH"`
    ff=`get_abs_path "$ff"`
    if [ "$ff" == "" ]; then
      print_error "The include file $f in file $head_file cannot be found. You
      may check CLICK_INCLUDE_PATH."
      exit
    fi
    #check (and remove) the existing ff in included_files list
    #INCLUDED_FILES=`echo $INCLUDED_FILES:$ff | awk -F : '{
    #                                      ns = ""; 
    #                                      split($0, a, ":");
    #                                      for (i = 0; i < NF; i++) { 
    #                                        if (a[i] != a[NF]){
    #                                          ns == "" ? ns = a[i] : ns = ns":"a[i]
    #                                        }
    #                                      };
    #                                     print ns }'`

    #check ff in INCLUDED_FILES
    local check=`echo $INCLUDED_FILES |sed -e 's/:/\n/g' |grep "$ff" 2>/dev/null`
    if [ "$check" == "" ]; then
      #recursive the build
      build_included_list "$ff"
      #insert ff into INCLUDED_FILES
      INCLUDED_FILES=$INCLUDED_FILES:$ff
      #recursive the build
      #build_included_list "$ff"
    fi
  done
}

#Build included list: is stored in INCLUDED_FILES
build_included_list "$ECLICK_FILE"
#Now, create complete - flat click file
for f in `echo $INCLUDED_FILES | sed -e 's/:/\n/g'`; do 
  cat "$f" >> $OUTPUT
  if [ $? -ne 0 ]; then
    rm -f $OUTPUT 2>/dev/null
    exit -1
  fi
done

cat $ECLICK_FILE >> $OUTPUT

