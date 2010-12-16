#!/bin/bash

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/tools/libfuncs.sh 2>/dev/null

trap clean 2 EXIT SIGTERM

#clean () { return }

option_config_add "DESCRIPTION" \
                  "draw-graph.sh" \
                  "1" \
                  "Drawing graph from traced packet dump file" 
option_config_add "--help" \
                  "HELP" \
                  "0" \
                  "Help on draw-graph.sh"
option_config_add "-h" \
                  "HELP" \
                  "0" \
                  "Help on draw-graph.sh"
option_config_add "-o" \
                  "OUTPUT" \
                  "1" \
                  "Output file name (for example: h.png)"
option_config_add "-f" \
                  "DUMPFILES" \
                  "1" \
                  "Dump file from click or tcpdump. Can use this option many
                  times to draw some lines in graph"
option_config_add "--packet-count" \
                  "PACKETCOUNT" \
                  "0" \
                  "Insert more parameter: packet count"
option_config_add "--xrange" \
                  "XRANGE" \
                  "1" \
                  "Range of X axes (for example: 0:1, or 10:100, ...)"
option_config_add "--xlabel" \
                  "XLABEL" \
                  "1" \
                  "Label of X axes."
option_config_add "--xcol" \
                   "XCOL" \
                   "1" \
                   "Column of X in dataset (dumpfile)"
option_config_add "--yrange" \
                  "YRANGE" \
                  "1" \
                  "Range of Y axes (for example: 0:1, or 10:100, ...)"
option_config_add "--ylabel" \
                  "YLABEL" \
                  "1" \
                  "Label of Y axes."
option_config_add "--ycol" \
                  "YCOL" \
                  "1" \
                  "Column of Y in dataset (dumpfile)"
option_config_add "--title" \
                  "TITLE" \
                  "1" \
                  "Title of the graph. For example: Arrival Curve of input packet"
option_parse "$@"

if [ "$HELP" == "true" ]; then
  option_usage_print
  exit 0
fi

if [ "$XLABEL" == "" ]; then
  XLABEL="x"
fi

if [ "$XCOL" == "" ]; then
  XCOL=2
fi

if [ "$YLABEL" == "" ]; then
  YLABEL="y"
fi
 
if [ "$YCOL" == "" ]; then
  YCOL=1
fi

if [ "$OUTPUT" == "" ]; then
  OUTPUT=/dev/stdout
fi

#convert dump file to human readable file (using to plot)
DUMPFILES=`echo $DUMPFILES | sed -e 's/:/ /g'`
for f in $DUMPFILES; do
  #if [ "$PACKETCOUNT" == "true" ]; then
    convert-click-dump.sh -f $f --packet-count -o `basename $f`.convert.pc
  #else
    convert-click-dump.sh -f $f -o `basename $f`.convert
  #fi
  #register_tmp_file `basename $f`.convert
done

#prepare gnuplot
#using draw-graph.pg.template
PLOTSCRIPT=./draw-graph-`date +%s`.pg
register_tmp_file $PLOTSCRIPT
cat $FILEDIR/plot-template/draw-graph.pg.template | \
                      sed -e s:XLABEL:${XLABEL}:g \
                          -e s:YLABEL:${YLABEL}:g \
                          -e s:XCOL:${XCOL}:g \
                          -e s:YCOL:${YCOL}:g \
                          -e s:OUTPUT:${OUTPUT}:g > $PLOTSCRIPT

register_tmp_file /tmp/tmpfile

find_value_x () {
  local datafile=$1
  local yy=$2
  while read y x info; do
    if [ "${yy}" == "${y}" ]; then
      echo $x
      return
    fi
  done < $datafile
}

find_value_y () {
  local datafile=$1
  local xx=$2
  while read y x info; do
    if [ "${xx}" == "${x}" ]; then
      echo $y
      return
    fi
  done < $datafile
} 

if [ "$XRANGE" == "" ]; then
  touch /tmp/tmpfile
  #Remove "set xrange" statement
  cat $PLOTSCRIPT | sed -e 's:set xrange:#set xrange:g' > /tmp/tmpfile
  cat /tmp/tmpfile > $PLOTSCRIPT
else
  touch /tmp/tmpfile
  cat $PLOTSCRIPT | sed -e s/XRANGE/${XRANGE}/g > /tmp/tmpfile
  cat /tmp/tmpfile > $PLOTSCRIPT
fi

if [ "$YRANGE" == "" ]; then
  touch /tmp/tmpfile
  #Remove "set xrange" statement
  cat $PLOTSCRIPT | sed -e 's:set yrange:#set yrange:g' > /tmp/tmpfile
  cat /tmp/tmpfile > $PLOTSCRIPT
else
  ymin=`echo $YRANGE |awk -F : '{print $1}'`
  ymax=`echo $YRANGE |awk -F : '{print $2}'`
  
  touch /tmp/tmpfile
  if [ "$PACKETCOUNT" == "true" ]; then
    cat $PLOTSCRIPT | sed -e s/YRANGE/${YRANGE}/g > /tmp/tmpfile
  else
    cat $PLOTSCRIPT | sed -e s/YRANGE/0:2/g > /tmp/tmpfile
  fi
  cat /tmp/tmpfile > $PLOTSCRIPT
  #try to modify XRANGE
  xmin=9999999999.9
  xmax=0.1
  for f in $DUMPFILES; do
    dumpfile_conv=`basename $f`.convert.pc
    t=`find_value_x $dumpfile_conv $ymin`
    if [ `echo "$t < $xmin" |bc` -eq 1 ]; then
      xmin=$t
    fi
    t=`find_value_x $dumpfile_conv $ymax`
    if [ `echo "$t > $xmax" |bc` -eq 1 ]; then
      xmax=$t
    fi
  done
  if [ "$xmin" != "" -a "$xmax" != "" ]; then
    cat $PLOTSCRIPT | sed -e 's:#set xrange:set xrange:g' > /tmp/tmpfile
    cat /tmp/tmpfile | sed -e s/XRANGE/${xmin}:${xmax}/g > $PLOTSCRIPT
  fi
fi

count=0
for f in $DUMPFILES; do
  if [ "$PACKETCOUNT" == "true" ]; then
    datafile=`basename $f`.convert.pc
  else
    datafile=`basename $f`.convert
  fi

  if [ $count -eq 0 ]; then
    PLOTSTR="\"$datafile\" using $XCOL:$YCOL title \"`basename $f`\" \\"
  else
    PLOTSTR=",\"$datafile\" using $XCOL:$YCOL title \"`basename $f`\" \\"
  fi
  count=1
  echo $PLOTSTR >> $PLOTSCRIPT
done

#Do plotting
chmod +x $PLOTSCRIPT
$PLOTSCRIPT
