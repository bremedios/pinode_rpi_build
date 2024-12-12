#!/bin/bash
CWD=`pwd`

MODULES=("libbpl_sys" "libdevices_dht22" "libbpl_storage" "libbpl_net" "pinode")
BRANCH=stable

BUILD_UPDATE=0
BUILD_DEPENDS=0
BUILD_PROG=0
BUILD_PROGS=0

usage() {
	echo "build_and_install.sh <command>"
	echo ""
	echo "    <No Command Specified>"
	echo "        Builds program"
	echo "    --depends"
	echo "        Builds and installs program dependencies"
	echo "    --update"
	echo "        Update source packages"
	echo "    --all"
	echo "        Builds programs and dependencies"
}

if [ $# -eq 0 ] ; then
	BUILD_UPDATE=1	
	BUILD_PROG=1
elif [ $# -eq 1 ] ; then
	if [ "$1" = "--depends" ] ; then
		BUILD_DEPENDS=1
	elif [ "$1" == "--update" ] ; then
		BUILD_UPDATE=1
	elif [ "$1" = "--all" ] ; then
		BUILD_DEPENDS=1
		BUILD_UPDATE=1
		BUILD_PROG=1
	else
		echo "Invalid arguments"
		exit 0
	fi
fi

if [ $BUILD_DEPENDS -ne 0 ] ; then
	#
	#   Wiring Pi build
	#
	git clone https://github.com/WiringPi/WiringPi.git

	cd WiringPi

	./build
	cd $CWD

	git clone https://github.com/fmtlib/fmt.git

	cd fmt

	cmake .

	cmake --build . --target fmt -j 4

	sudo cmake --install .

	cd $CWD
fi

if [ $BUILD_UPDATE -ne 0 ] ; then
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
	done
fi

if [ $BUILD_PROG -ne 0 ] ; then
	echo "cmake -B cmake-build-debug -S ."
	cmake -B cmake-build-debug -S .

	echo "cmake --build -B cmake-build-debug -j 4"
	cmake --build cmake-build-debug -j 4

	echo "sudo cmake --install -B cmake-build-debug"
	sudo cmake --install cmake-build-debug
fi

if [ $BUILD_PROGS -ne 0 ] ; then
	#
	#   Clone then build each module
	#
	for MOD in ${MODULES[@]}; do
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

	mkdir -p ~/.config/autostart

	cp -rv config/autostart/* ~/.config/autostart/

	sudo ldconfig
fi
