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
	#
	#   Checkout the branch only if it does not already exist
	#
	if [ ! -d $MOD ]; then
		git clone https://github.com/bremedios/$MOD.git
		git checkout $BRANCH
	fi

	cd $MOD
	git pull

	cmake .

	retval=$?

	if [ $retval -ne 0 ]; then
		echo "CMAKE failed for $MOD"
		exit $retval
	fi

	make

	retval=$?

	if [ $retval -ne 0 ]; then
		echo "Failed to build $MOD"
		exit $retval
	fi

	sudo make install

	retval=$?

	if [ $retval -ne 0 ]; then
		echo "Installtion failed for $MOD"
		exit $retval
	fi

	cd $CWD
done

sudo ldconfig
