#!/bin/bash
. ../load_env.bash
shopt -s expand_aliases
CURR_DIR="files/Stage2"
wd=`pwd`

make > /dev/null 2>&1
./a.out test.txt
cd $PROJ_DIR
./xsm -e $CURR_DIR/intermediate.xsm -l $CURR_DIR/library.lib
cd $wd
make clean > /dev/null
