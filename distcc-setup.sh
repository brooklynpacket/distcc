#!/bin/sh

set -e

create_profile()
{
	echo "#!/bin/sh" > ~/distcc/tinyco/profile
	echo "export DISTCC_ENABLED=true" >> ~/distcc/tinyco/profile
}

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

	sudo mkdir -m 777 /Library/Developer/Xcode || true
	sudo mkdir -m 777 /Library/Developer/Xcode/DerivedData || true
	sudo mkdir -m 777 /Library/Developer/Xcode/DerivedData/ModuleCache || true
	touch /Library/Developer/Xcode/DerivedData/ModuleCache/Session.modulevalidation
	sudo chmod 666 /Library/Developer/Xcode/DerivedData/ModuleCache/Session.modulevalidation

	sudo touch ~/.distcc/hosts
	sudo chmod 666 ~/.distcc/hosts

	create_profile
}

usage()
{
	echo "Options:\n"
	echo "-i       Install distcc, set up a launch agent, and start build server"
	echo "-p       Create the profile file"
}

while [ "$1" != "" ]
do
	case $1 in
		-i )	setup
				exit
				;;
		-p )	create_profile
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
