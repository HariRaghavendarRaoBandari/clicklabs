#!/bin/bash
# This script support to install new click elements
# New click elements are put in elements/local
# iizke

unset CLICK_SRC
. ~/.bashrc

CURRENT_DIR=`pwd`
#CLICK_SRC=/home/iizke/click/click-1.8.0
if [ "$CLICK_SRC" == "" ]; then
	CLICK_SRC=$(cat $(find / -wholename "*click/srcdir" 2>/dev/null | head -1) 2>/dev/null)
	if [ "$CLICK_SRC" == "" ]; then
		echo Maybe you do not install click. Please install it before continuing.
		exit 1
	fi
	echo CLICK_SRC is $CLICK_SRC
	echo "export CLICK_SRC=${CLICK_SRC}" >> ~/.bashrc
	export CLICK_SRC=${CLICK_SRC}
fi

mkdir -p $CLICK_SRC/elements/local
cp elements/*.cc elements/*.hh $CLICK_SRC/elements/local
cd $CLICK_SRC
make elemlist
make
if [ $? -eq 0 ]; then
	sudo make install
fi
cd $CURRENT_DIR
