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

REQUIRED_VERSION=$(cat cli-version | grep version:)
if [ "$CL_VERSION" != "$REQUIRED_VERSION" ]
then
	echo "Local command line tools $CL_VERSION does not match required $REQUIRED_VERSION"
	echo "Removing network name from hosts file"
	cat hosts | grep -v "$HOSTNAME" | sudo tee hosts
	COMMIT_MSG="distccd.sh removed network name from host file"
	commit_hosts
	exit 1
fi

HOSTS_ID=$(cat hosts | grep "$HOSTNAME") || true

if [ "$HOSTS_ID" == "" ]
then
	echo "Adding name to hosts file"
	echo "$HOSTNAME.\n" | sudo tee -a hosts
	COMMIT_MSG="distccd.sh added network name to host file"
	commit_hosts
fi

/usr/local/bin/distccd --no-detach --daemon --allow 127.0.0.1 --allow 10.1.0.0/16 --log-stderr --verbose
