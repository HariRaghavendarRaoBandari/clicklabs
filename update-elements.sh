#!/bin/sh

CURRENT_DIR=`pwd`
CLICK_SRC=/home/iizke/click/click-1.8.0
mkdir -p $CLICK_SRC/elements/local
cp elements/*.cc elements/*.hh $CLICK_SRC/elements/local
cd $CLICK_SRC
make
if [ $? -eq 0 ]; then
	sudo make install
fi
cd $CURRENT_DIR
