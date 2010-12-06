#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/tools/libfuncs.sh 2>/dev/null
FILEDIR=$(get_abs_path $FILEDIR)

clean () {
  killall -9 click 2>/dev/null
  killall -9 clicky 2>/dev/null
}

trap clean 2 EXIT SIGTERM

usage () {
  echo -e "\

  ${bold}DESCRIPTION${txtrst}
    Initialize enviroment for ClickLabs: Setting path for visual-clicky.sh
    (tool for visualize click experiment) and update new implemented click elements.

    ${bold}SYNOPSIS${txtrst}
      ${txtylw}${bold}init.sh  [${txtylw}${bold}-h | --help${txtrst}]
               [${txtylw}${bold}-s | --click-src${txtrst} CLICK-SOURCE-PATH]"
}

option_config_add "-h"            "HELP"      "0" "Help on init"
option_config_add "--help"        "HELP"      "0" "Help on init"
option_config_add "-s"            "CLICK_SRC" "1" "Click source path"
option_config_add "--click-src"   "CLICK_SRC" "1" "Click source path"
option_parse "$@"

if [ "$HELP" == "true" ]; then
  usage
  exit 0
fi

#Setting PATH for visual-click
if [ -f $FILEDIR/visual-clicky.sh ]; then
  EXPSTR="export PATH=\$PATH:$FILEDIR"
  count=`cat ~/.bashrc|grep -e "export PATH=\\\$PATH:$FILEDIR"|wc -l`
  if [ $count -eq 0 ]; then
    echo $EXPSTR >> ~/.bashrc
  fi
fi

#Detect and set Click source path to file ~/.clickrc
if [ "$CLICK_SRC" != "" ]; then
  # This info from user, so please using absolute path
  CLICK_SRC=$(get_abs_path $CLICK_SRC)
  if [ "$CLICK_SRC" == "" ]; then
    print_info "You provide an incorrect path of Click source. It will be
      detected from file ~/.clickrc or search for file click/srcdir."
  else
    echo "export CLICK_SRC=${CLICK_SRC}" > ~/.clickrc
  fi
fi
print_info "Checking CLICK Source from file ~/.clickrc ..."
source ~/.clickrc 2>/dev/null
print_info "    CLICK_SRC = $CLICK_SRC".
if [ "$CLICK_SRC" == "" ]; then
  print_info "Auto-detecting the Click source path (normally, it is long time, but you can use option -s or --click-src to ignore this action) ..."
  CLICK_SRC=$(cat $(find / -wholename "*click/srcdir" 2>/dev/null | head -1) 2>/dev/null)
  if [ "$CLICK_SRC" == "" ]; then
    print_error "Maybe you do not install click. Please install it before continuing."
    exit 1
  fi 
  print_info "CLICK source path is: ${CLICK_SRC}"
  echo "export CLICK_SRC=${CLICK_SRC}" > ~/.clickrc
fi

source $FILEDIR/update-elements.sh

