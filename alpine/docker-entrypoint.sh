#!/bin/sh

set -e

# Add `java -jar /wiremock-standalone.jar` as command if needed
if [ "${1#-}" != "$1" ]; then
	set -- java -cp /var/wiremock/lib/*:/var/wiremock/extensions/* com.github.tomakehurst.wiremock.standalone.WireMockServerRunner "$@"
fi

# allow the container to be started with `-e uid=`
if [ "$uid" != "" ]; then
	# Change the ownership of /home/wiremock to $uid
	chown -R $uid:$uid /home/wiremock

	set -- su-exec $uid:$uid "$@"
fi

if [ -n "${WIREMOCK_ARGS}" ]
then
  echo "WARNING !! WIREMOCK_ARGS environment variable is now deprecated, it will be removed in a future version"
fi

exec "$@"
