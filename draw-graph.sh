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
option_config_add "--plot-type" \
                  "PLOTTYPE" \
                  "1" \
                  "Type of plotting data. It can be: RATE, COUNT (Default) or DENSITY"
option_config_add "--data" \
                  "DATA" \
                  "1" \
                  "Data for plotting"

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

if [ "$PLOTTYPE" == "" ]; then
  PLOTTYPE="COUNT"
fi

#Prepare data for plotting
#Convert dump file to human readable file (using to plot)
 
DUMPFILES=`echo $DUMPFILES | sed -e 's/:/ /g'`
DATA=`echo $DATA | sed -e 's/:/ /g'`
for f in $DUMPFILES; do
  CONVERTFILE=""
  _CONVERTFILE=""
  if [ "$PLOTTYPE" == "COUNT" ]; then
    CONVERTFILE=`basename $f`.convert.pc
    convert-click-dump.sh -f $f --packet-count -o $CONVERTFILE
  else
    _CONVERTFILE=`basename $f`.convert
    convert-click-dump.sh -f $f -o $_CONVERTFILE
    if [ "$PLOTTYPE" == "RATE" ]; then
      pt=0
      c=1 # count number of packets in a very small interval (0 division)
      while read n t; do
        #if [ "$pt" == "0" ]; then 
        #  pt=$t
        #  continue
        #fi
        if [ "$t" == "$pt" ]; then
          c=$((c+1))
          continue
        fi
        freq=`echo $c $pt $t | awk '{print $1/($3-$2)}'`
        CONVERTFILE=`basename $f`.convert.rate
        echo $freq $t >> $CONVERTFILE
        pt=$t
        c=1
      done < $_CONVERTFILE
    else
      CONVERTFILE=$_CONVERTFILE
    fi
  fi
  #Aggregate Converted_dump_file to DATA
  #but remove the built-in data (future)
  DATA="$DATA $CONVERTFILE"

  #register_tmp_file $CONVERTFILE
  #register_tmp_file $_CONVERTFILE
  #register_tmp_file `basename $f`.convert.rate
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

find_maxmin_x () {
  local maxx=0
  for f in $DATA; do
    local tmpx=""
    tmpx=`cat $f | head -1 | awk '{print $2}'`
    local check=`echo "$maxx < $tmpx" |bc`
    if [ $check -eq 1 ]; then
      maxx=$tmpx
    fi
  done
  echo $maxx
}

if [ "$XRANGE" == "" ]; then
  touch /tmp/tmpfile
  #Remove "set xrange" statement
  cat $PLOTSCRIPT | sed -e 's:set xrange:#set xrange:g' > /tmp/tmpfile
  cat /tmp/tmpfile > $PLOTSCRIPT
else
  touch /tmp/tmpfile
  maxminx=`find_maxmin_x`
  x1=`echo $XRANGE | awk -F : '{printf "%.16f", $1}'`
  x2=`echo $XRANGE | awk -F : '{printf "%.16f", $2}'`
  if [ `echo "$x1 == 0" | bc` -eq 1 ]; then
    x1=$maxminx
    x2=`echo $x1 $x2 | awk '{printf "%.16f", $1+$2}'`
    XRANGE="$x1:$x2"
  fi
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
  register_tmp_file /tmp/tmpfile

  if [ "$PLOTTYPE" == "DENSITY" ]; then
    cat $PLOTSCRIPT | sed -e s/YRANGE/0:2/g > /tmp/tmpfile
  else
    cat $PLOTSCRIPT | sed -e s/YRANGE/${YRANGE}/g > /tmp/tmpfile
  fi
  cat /tmp/tmpfile > $PLOTSCRIPT

  #try to modify XRANGE
  #xmin=9999999999.9
  #xmax=0.1
  #for f in $DATA; do
  #  t=`find_value_x $f $ymin`
  #  if [ `echo "$t < $xmin" |bc` -eq 1 ]; then
  #    xmin=$t
  #  fi
  #  t=`find_value_x $f $ymax`
  #  if [ `echo "$t > $xmax" |bc` -eq 1 ]; then
  #    xmax=$t
  #  fi
  #done
  #if [ "$xmin" != "" -a "$xmax" != "" ]; then
  #  cat $PLOTSCRIPT | sed -e 's:#set xrange:set xrange:g' > /tmp/tmpfile
  #  cat /tmp/tmpfile | sed -e s/XRANGE/${xmin}:${xmax}/g > $PLOTSCRIPT
  #fi
fi

count=0
for f in $DATA; do
  if [ $count -eq 0 ]; then
    PLOTSTR="\"$f\" using $XCOL:$YCOL title \"`basename $f`\" \\"
  else
    PLOTSTR=",\"$f\" using $XCOL:$YCOL title \"`basename $f`\" \\"
  fi
  count=1
  echo $PLOTSTR >> $PLOTSCRIPT
done

#Do plotting
chmod +x $PLOTSCRIPT
$PLOTSCRIPT

