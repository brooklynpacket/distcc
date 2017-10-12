#!/bin/sh

exec >> ~/distcc/tinyco/logs/compile.log 2>&1

if [ -e ~/distcc/tinyco/profile.build ]
then
	. ~/distcc/tinyco/profile.build
fi

if [[ -n "$DISTCC_ENABLED" ]] && [ "$DISTCC_ENABLED" == true ]
then
	distcc "$@" || exit
	echo "Using distcc"
else
	clang++ "$@"
	echo "Not using distcc"
fi