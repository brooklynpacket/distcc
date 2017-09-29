#!/bin/sh

set -e

if [ "$DISTCC_ENABLED" != true ]
then
	echo "distcc not enabled"
	exit
fi

cd ~/distcc/tinyco
git fetch origin
git merge origin/master

REQUIRED_VERSION=$(cat cli-version | grep Xcode)
CURRENT_VERSION=$(xcodebuild -version | grep Xcode)

if [ "$REQUIRED_VERSION" != "$CURRENT_VERSION" ]
then
	cat profile | sed 's/DISTCC_CURRENT_BUILD_ENABLED=.*/DISTCC_CURRENT_BUILD_ENABLED=false/' | tee profile > /dev/null
	echo "Current version $CURRENT_VERSION is not the required version $REQUIRED_VERSION"
	exit
else
	cat profile | sed 's/DISTCC_CURRENT_BUILD_ENABLED=.*/DISTCC_CURRENT_BUILD_ENABLED=true/' | tee profile > /dev/null
fi

DISTCCD_PROCESSES=$(ps -A | grep "/usr/local/Cellar/distcc/3.2rc1/bin/distccd" | grep -v "grep") || true

if [ "$DISTCCD_PROCESSES" == "" ]
then
	./distccd.sh
fi

ping 10.0.3.255 -c 3 > /dev/null
wait $!

echo "" > "hosts.temp"

while read line || [[ -n "$line" ]]
do
	if [ "$line" != "" ]
	then
		arp -na | grep "$line" | sed 's/.*(\(.*\)).*/\1\/10/' >> "hosts.temp"
	fi
done < "hosts"

mv hosts.temp ~/.distcc/hosts