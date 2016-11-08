#!/bin/bash

set -e

# Add `java -jar /wiremock-standalone.jar` as command if needed
if [ "${1:0:1}" = "-" ]; then
	set -- java -jar /wiremock-standalone.jar "$@"
fi

# allow the container to be started with `-e uid=`
if [ "$1 $2 $3" = "java -jar /wiremock-standalone.jar" -a "$uid" != "" ]; then
	# Change the ownership of /home/wiremock to $uid
	chown -R $uid:$uid /home/wiremock

	set -- gosu $uid:$uid "$@"
fi

if [ -n "${WIREMOCK_ARGS}" ]
then
  echo "WARNING !! WIREMOCK_ARGS environment variable is now deprecated, it will be removed in a future version"
fi

exec "$@" ${WIREMOCK_ARGS}
