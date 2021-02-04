#!/bin/bash
. ../load_env.bash
shopt -s expand_aliases
CURR_DIR="files/Stage3"
wd=`pwd`

make > /dev/null 2>&1
./expl-bin $1
./ltranslate
cd $PROJ_DIR
./xsm -e $CURR_DIR/machinecode.xsm -l $CURR_DIR/library.lib
cd $wd
make clean > /dev/null
