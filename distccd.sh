#!/bin/sh

commit_hosts()
{
	git reset
	git add hosts
	git commit -m "$COMMIT_MSG"
	git push origin master
}

set -e

IFCONFIG=$(ifconfig | grep "inet \|ether " | sed 's/.*inet \(10\.0\.\).*/\1/') || true
IP_ADDRESS_VALID_PREFIX=$(echo "$IFCONFIG" | grep -v inet) || true
IP_ADDRESS=$(echo "$IFCONFIG" | grep "^10\.0\.") || true
if [ "$IP_ADDRESS_VALID_PREFIX" == "" ] || [ "$IP_ADDRESS" == "" ]
then
	echo "Must be on wired network to run server"
	exit 1
fi

cd ~/distcc/tinyco

git fetch origin
git merge origin/master

CL_VERSION=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version:)
echo "CLI Version: $CL_VERSION"

MAC_ADDRESS=$(echo $IFCONFIG | sed 's/.*ether \(.*\)\s*10\.0\..*/\1/' | sed 's/0\([0-9A-Fa-f]\)/\1/g' | tr '[:upper:]' '[:lower:]')
echo "MAC Address: $MAC_ADDRESS"

REQUIRED_VERSION=$(cat cli-version | grep version:)
if [ "$CL_VERSION" != "$REQUIRED_VERSION" ]
then
	echo "Local command line tools $CL_VERSION does not match required $REQUIRED_VERSION"
	echo "Removing MAC address from hosts file"
	cat hosts | grep -v "$MAC_ADDRESS" | tee hosts
	COMMIT_MSG="distccd.sh removed MAC address from host file"
	commit_hosts
	exit 1
fi

HOSTS_ID=$(cat hosts | grep "$MAC_ADDRESS") || true
echo "Hosts MAC: $HOSTS_ID"

if [ "$HOSTS_ID" == "" ]
then
	echo "Adding MAC address to hosts file"
	echo "$MAC_ADDRESS" | tee -a hosts
	COMMIT_MSG="distccd.sh added MAC address to host file"
	commit_hosts
fi

#export DISTCC_SAVE_TEMPS=1
#export TMPDIR=~/distcc/tinyco/logs/tmp

/usr/local/Cellar/distcc/3.2rc1/bin/distccd --daemon --allow 127.0.0.1 --allow 10.0.0.0/16 --log-file ~/distcc/tinyco/logs/distccd.log --verbose
