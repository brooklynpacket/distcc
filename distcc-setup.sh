#!/bin/sh

set -e

setup()
{
	brew install python3
	brew install autoconf
	brew install automake
	brew install distcc

	git clone https://github.com/PSPDFKit-labs/distcc ~/distcc
	cd ~/distcc
	git clone https://github.com/brooklynpacket/distcc tinyco

	./autogen.sh
	./configure --without-libiberty --disable-Werror
	make

	sudo cp distcc distccd distccmon-text lsdistcc pump /usr/local/Cellar/distcc/3.2rc1/bin/.
	cp tinyco/org.distccd.user.plist ~/Library/LaunchAgents/.
	sudo chown root:wheel ~/Library/LaunchAgents/org.distccd.user.plist
	sudo chmod 666 ~/Library/LaunchAgents/org.distccd.user.plist

	/usr/local/Cellar/distcc/3.2rc1/bin/distcc || true

	mkdir tinyco/logs
	touch tinyco/logs/distccd.log

	tinyco/distccd.sh

	sudo touch ~/.distcc/hosts
	sudo chmod 666 ~/.distcc/hosts

	echo "export DISTCC_ENABLED=true" >> ~/.bash_profile
	echo "export DISTCC_CURRENT_BUILD_ENABLED=true" >> ~/.bash_profile
}

usage()
{
	echo "Options:\n"
	echo "-i       Install distcc, set up a launch agent, and start build server"
}

while [ "$1" != "" ]
do
	case $1 in
		-i )	setup
				exit
				;;
		-h )	usage
				exit
				;;
		* )		usage
				exit 1
	esac
	shift
done
