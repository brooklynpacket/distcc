#!/bin/sh

set -e

cd /usr/local/tinyco/distcc/tinyco
sudo git fetch origin
sudo git merge origin/master

sudo echo "127.0.0.1" > "hosts.temp"

while read line || [[ -n "$line" ]]
do
	if [ "$line" != "" ]
	then
		arp -na | grep "$line" | sed 's/.*(\(.*\)).*/\1/' >> "hosts.temp"
	fi
done < "hosts"

sudo mv hosts.temp ~/.distcc/hosts