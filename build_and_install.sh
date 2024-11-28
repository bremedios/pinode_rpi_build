#!/bin/bash
CWD=`pwd`

MODULES=("WiringPi" "libbpl_sys" "libdevices_dht22" "libbpl_storage" "libbpl_net" "pinode")

#
#   Update all git submodules
#
git submodule update --init --recursive

for MOD in ${MODULES[@]}; do
	cd $CWD/$MOD
	mkdir -p cmake-build
	cd cmake-build
	cmake ../
	make
	sudo make install
	cd $CWD
done

