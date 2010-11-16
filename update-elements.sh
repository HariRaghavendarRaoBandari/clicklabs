#!/bin/bash
# This script supports to install new click elements
# New click elements are put in elements/local
# iizke

FILEDIR=$(dirname $(which $BASH_SOURCE))
# Bash shell script library functions
source $FILEDIR/tools/libfuncs.sh 2>/dev/null
# File .clickrc represents the Click source path 
source ~/.clickrc 2>/dev/null

CURRENT_DIR=`pwd`
#CLICK_SRC=/home/iizke/click/click-1.8.0
if [ "$CLICK_SRC" == "" ]; then
	print_info "Auto-detecting the Click source path ..."
	CLICK_SRC=$(cat $(find / -wholename "*click/srcdir" 2>/dev/null | head -1) 2>/dev/null)
	if [ "$CLICK_SRC" == "" ]; then
		print_error "Maybe you do not install click. Please install it before continuing."
		exit 1
	fi
	echo "export CLICK_SRC=${CLICK_SRC}" > ~/.clickrc
fi

# Check CLICK_SRC path in case of Loading from file ~/.clickrc
if [ ! -d "${CLICK_SRC}" ]; then
	print_error "Click source \(${CLICK_SRC}\) does not exist. Please check it again and update in or simply delete file ~/.clickrc for autodetecting the Click source path."
	exit
fi

print_info "CLICK_SRC is ${CLICK_SRC}"
mkdir -p $CLICK_SRC/elements/local
cp elements/*.cc elements/*.hh $CLICK_SRC/elements/local
cd $CLICK_SRC
print_warn "Before rebuilding the Click source for updating the new elements, need to configure with --enable-local option in the first time Click is installed: ./configure --enable-local"
make elemlist
make
if [ $? -eq 0 ]; then
	sudo make install
fi
cd $CURRENT_DIR
