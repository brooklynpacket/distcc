#!/bin/sh

set -e

disable()
{
	echo "" > ~/.distcc/hosts
	exit
}

if [ ! -e ~/distcc/tinyco/profile ]
then
	echo '#!/bin/sh' > ~/distcc/tinyco/profile
	echo 'export DISTCC_ENABLED=true' >> ~/distcc/tincyo/profile
fi

. ~/distcc/tinyco/profile

if [ "$DISTCC_ENABLED" != true ]
then
	echo "distcc not enabled"
	disable
fi

cd ~/distcc/tinyco
git fetch origin
git merge origin/master

REQUIRED_VERSION=$(cat cli-version | grep Xcode)
CURRENT_VERSION=$(xcodebuild -version | grep Xcode)

if [ "$REQUIRED_VERSION" != "$CURRENT_VERSION" ]
then
	echo "Current version $CURRENT_VERSION is not the required version $REQUIRED_VERSION"
	disable
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
		LOCAL_MAC=$(ifconfig -a | grep "$line") || true
		if [ "$LOCAL_MAC" == "" ]
		then
			arp -na | grep "$line" | sed 's/.*(\(.*\)).*/\1/' >> "hosts.temp"
		fi
	fi
done < "hosts"

echo "--randomize" >> "hosts.temp"
#echo "LOCAL_HOST = localhost | --localslots_cpp=8" >> "hosts.temp"

mv hosts.temp ~/.distcc/hosts

cat profile > profile.build
#pump --startup >> profile.build

echo "" > logs/compile.log