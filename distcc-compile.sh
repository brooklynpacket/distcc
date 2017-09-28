#!/bin/sh

exec > ~/distcc/tinyco/logs/compile.log 2>&1

. ~/distcc/tinyco/profile-copy

if [ "$DISTCC_ENABLED" == true ] && [ "$DISTCC_CURRENT_BUILD_ENABLED" == true ]
then
	distcc clang++ "$@"
	echo "Using distcc"
else
	clang++ "$@"
	echo "Not using distcc"
fi