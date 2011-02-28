#!/bin/bash
# iizke

FILEDIR=$(dirname $(which $BASH_SOURCE))
CLICKLAB_HOME=$FILEDIR/..
# Bash shell script library functions
source $CLICKLAB_HOME/libs/libfuncs.sh 2>/dev/null

trap clean EXIT SIGTERM

STAMP=`date  +%y-%m-%d-%H-%M-%S`
TMPDIR=/tmp/clicklabs-$STAMP
mkdir -p $TMPDIR
register_tmp_file $TMPDIR
if [ $? -ne 0 ]; then
  print_error "Cannot create new directory in /tmp. Please check!"
  exit
fi

cp -r $CLICKLAB_HOME $TMPDIR
CURRENT_DIR=`pwd`
cd $TMPDIR
# remove unnecessary files: .svn, docs, dump
echo Removing .svn directories ...
find . -name "*.svn*" -exec rm -rf {} \; 2>/dev/null
echo Removing docs ...
cp docs/report.pdf .
rm -rf docs
echo Removing dump ...
rm -rf dump
echo Create zip file clicklabs-$STAMP.zip ...
cd ..
zip -r $CURRENT_DIR/clicklabs-$STAMP.zip clicklabs-$STAMP
#Finish
echo Package clicklabs is at: $CURRENT_DIR/clicklabs-$STAMP.zip
cd $CURRENT_DIR
