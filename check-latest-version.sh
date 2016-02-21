#!/bin/bash

LATEST_VERSION=$(curl -s http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/maven-metadata.xml | grep '<latest' | cut -f2 -d">" | cut -f1 -d"<")

sed -i "s/LATEST_VERSION=\(.*\)/LATEST_VERSION=$LATEST_VERSION/" version.properties
