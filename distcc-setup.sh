#!/bin/sh

set -e

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