#!/bin/bash
. ../load_env.bash
shopt -s expand_aliases
CURR_DIR="files/Stage8"
wd=`pwd`

make > /dev/null 2>&1
./expl-bin $1
./ltranslate
cd $PROJ_DIR
./xsm -l $CURR_DIR/library.lib -e $CURR_DIR/machinecode.xsm --debug
cd $wd
#make clean > /dev/null
