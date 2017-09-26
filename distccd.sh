#!/bin/sh

commit_hosts()
{
	sudo git reset
	sudo git add hosts
	sudo git commit -m "$COMMIT_MSG"
	sudo git push origin master
}

set -e

cd /usr/local/tinyco/distcc/tinyco

sudo git fetch origin
sudo git merge origin/master

CL_VERSION=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version:)
echo "CLI Version: $CL_VERSION"

MAC_ADDRESS=$(ifconfig en0 | grep ether | sed 's/.*ether \(.*\)/\1/' | sed 's/0\([0-9A-Fa-f]\)/\1/g' | tr '[:upper:]' '[:lower:]')
echo "MAC Address: $MAC_ADDRESS"

REQUIRED_VERSION=$(cat cli-version | grep version:)
if [ "$CL_VERSION" != "$REQUIRED_VERSION" ]
then
	echo "Local command line tools $CL_VERSION does not match required $REQUIRED_VERSION"
	echo "Removing MAC address from hosts file"
	cat hosts | grep -v "$MAC_ADDRESS" | sudo tee hosts
	COMMIT_MSG="distccd.sh removed MAC address from host file"
	commit_hosts
	exit 1
fi

HOSTS_ID=$(cat hosts | grep "$MAC_ADDRESS") || true
echo "Hosts MAC: $HOSTS_ID"

if [ "$HOSTS_ID" == "" ]
then
	echo "Adding MAC address to hosts file"
	echo "$MAC_ADDRESS" | sudo tee -a hosts
	COMMIT_MSG="distccd.sh added MAC address to host file"
	commit_hosts
fi

/usr/local/bin/distccd --no-detach --daemon --allow 127.0.0.1 --allow 10.1.0.0/16 --log-stderr --verbose
