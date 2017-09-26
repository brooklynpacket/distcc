#!/bin/sh

set -e

cd ~/Documents/tinyco/distcc
git fetch origin
git merge origin/master

ping 10.1.3.255 -c 3 > /dev/null
wait $!

echo "127.0.0.1" > "hosts.temp"

while read line || [[ -n "$line" ]]
do
	if [ "$line" != "" ]
	then
		arp -na | grep "$line" | sed 's/.*(\(.*\)).*/\1/' >> "hosts.temp"
	fi
done < "hosts"

mv hosts.temp ~/.distcc/hosts