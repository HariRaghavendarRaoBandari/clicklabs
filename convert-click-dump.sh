#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/tools/libfuncs.sh 2>/dev/null

clean () {
  rm -f $tmpfile
  return
}

trap clean 2 EXIT SIGTERM

#Default value
PACKETCOUNT="false"
DUMPFILE=""
HELP="false"
EXITCOUNT=""

option_config_add "DESCRIPTION" \
                  "convert-click-dump.sh" \
                  "1" \
                  "Transform tcpdump-like packet trace file into human-readable file" 
option_config_add "--help" \
                  "HELP" \
                  "0" \
                  "Help on convert-click-dump.sh"
 option_config_add "-h" \
                   "HELP" \
                   "0" \
                   "Help on convert-click-dump.sh"
option_config_add "--dumpfile" \
                  "DUMPFILE" \
                  "1" \
                  "Dump file from click or tcpdump"
option_config_add "-f" \
                  "DUMPFILE" \
                  "1" \
                  "Dump file from click or tcpdump"
option_config_add "_" \
                  "DUMPFILE" \
                  "1" \
                  "Dump file from click or tcpdump" 
option_config_add "--packet-count" \
                  "PACKETCOUNT" \
                  "0" \
                  "Insert more parameter: packet count"
option_config_add "-c" \
                  "EXITCOUNT" \
                  "1" \
                  "Exit after get enough number of packet (ARG)"
option_config_add "-o" \
                  "OUTPUT" \
                  "1" \
                  "Output file when conversion is finished."

option_parse "$@"

if [ "$HELP" == "true" ]; then
  option_usage_print
  exit 0
fi

if [ "$EXITCOUNT" == "" ]; then
  TCPOPT=""
else
  TCPOPT="-c $EXITCOUNT"
fi

if [ "$OUTPUT" == "" ]; then
  OUTPUT=/dev/output
fi

# convert binary dump file to human reading file
modified_time=$(ls --time-style="+%s" -l $DUMPFILE | awk '{print $6}')
tmpfile=/tmp/$modified_time-`basename $DUMPFILE`

tcpdump -s 1 -r $DUMPFILE $TCPOPT -tt | sort > $tmpfile
sleep 1

#line_tmpfile=./`basename $DUMPFILE`-$modified_time.dump
if [ "$PACKETCOUNT" == "true" ]; then
  cat $tmpfile -n > $OUTPUT
else
  cat $tmpfile | awk '{print 1 " " $1}' > $OUTPUT
fi
rm -f $tmpfile
