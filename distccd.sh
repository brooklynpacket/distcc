#!/bin/sh

set -e

cd /usr/local/tinyco/distcc/tinyco

git fetch origin
git merge origin/master

CL_VERSION=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version:)
echo "CLI Version: $CL_VERSION"

REQUIRED_VERSION=$(cat hosts | grep version:)
if [ "$CL_VERSION" != "$REQUIRED_VERSION" ]; then
	echo "Local command line tools $CL_VERSION does not match reßquired $REQUIRED_VERSION"
	exit 1
fi

MAC_ADDRESS=$(ifconfig en0 | grep ether | sed 's/.*ether \(.*\)/\1/' | sed 's/0\([0-9A-Fa-f]\)/\1/g' | tr '[:upper:]' '[:lower:]')
echo "MAC Address: $MAC_ADDRESS"

HOSTS_MAC=$(cat ./hosts | grep $MAC_ADDRESS)
echo "Hosts MAC: $HOSTS_MAC"

if [ "$HOSTS_MAC" == "" ]; then
	echo "Adding address to hosts file"
	echo "\n$MAC_ADDRESS" >> ./hosts
	git add hosts
	git commit -m "distccd.sh added MAC address to host file"
	git push origin master
fi

/usr/local/bin/distccd --no-detach --daemon --allow 127.0.0.1 --log-stderr