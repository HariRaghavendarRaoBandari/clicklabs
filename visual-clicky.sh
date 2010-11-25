#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/tools/libfuncs.sh 2>/dev/null

clean () {
  killall -9 click 
  killall -9 clicky
}

trap clean 2

CLICK_FILE=$1
PORT=$2
CCSS_FILE=$3

if [ "$CCSS_FILE" = "" ]; then
  CCSS_FILE=./clicky.ccss
fi

if [ "$PORT" = "" ]; then
  PORT=8001
fi

click -p $PORT $CLICK_FILE &
sleep 1
clicky -p $PORT -s $CCSS_FILE 
