#!/bin/sh

set -e

setup()
{
	brew install python3
	brew install autoconf
	brew install automake
	brew install distcc

	sudo git clone https://github.com/PSPDFKit-labs/distcc /usr/local/tinyco/distcc
	cd /usr/local/tinyco/distcc
	sudo git clone https://github.com/brooklynpacket/distcc tinyco

	sudo ./autogen.sh
	sudo ./configure --without-libiberty --disable-Werror
	sudo make

	sudo cp distcc distccd distccmon-text lsdistcc pump /usr/local/Cellar/distcc/3.2rc1/bin/.
	sudo cp tinyco/org.distccd.user.plist /Library/LaunchDaemons/.
	sudo chown root:wheel /Library/LaunchDaemons/org.distccd.user.plist
	sudo chmod 644 /Library/LaunchDaemons/org.distccd.user.plist

	/usr/local/Cellar/distcc/3.2rc1/bin/distcc || true

	tinyco/distccd.sh
}

setup_project()
{
	if [ ! -d "~/Documents/tinyco/distcc" ]
	then
		git clone https://github.com/brooklynpacket/distcc ~/Documents/tinyco/distcc
	fi

	sudo touch ~/.distcc/hosts
	sudo chmod 666 ~/.distcc/hosts
}

usage()
{
	echo "Options:\n\n"
	echo "-i                                 Install distcc, set up a launch daemon, and start build server"
	echo "-u                                 Uninstall distcc and unregister as a build server"
	echo "-p /Path/To/project.xcodeproj      Set up XCode project to build using distcc"
	echo "-c /Path/To/project.xcodeproj      Remove distcc from project build settings"
}

while [ "$1" != "" ]
do
	case $1 in
		-i )	setup
				exit
				;;
		-p )	project_path=$1
				setup_project
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
