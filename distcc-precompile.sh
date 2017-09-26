#!/bin/sh

set -e

cd ~/Documents/tinyco/distcc
git fetch origin
git merge origin/master
cp hosts ~/.distcc/hosts
