#!/bin/bash
CWD=`pwd`

MODULES=("libbpl_sys" "libdevices_dht22" "libbpl_storage" "libbpl_net" "pinode")
BRANCH=stable

#
#   Wiring Pi build
#
git clone https://github.com/WiringPi/WiringPi.git

cd WiringPi
./build
cd $CWD

#
#   Clone then build each module
#
for MOD in ${MODULES[@]}; do
	git clone https://github.com/bremedios/$MOD.git
	cd $MOD
	git checkout $BRANCH

	mkdir -p cmake-build
	cd cmake-build
	cmake ../
	make
	sudo make install
	cd $CWD
done
