#!/bin/bash

echo -n "WIREMOCK_VERSION=" > version.properties
curl -s http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/maven-metadata.xml | grep '<latest' | cut -f2 -d">"|cut -f1 -d"<" >> version.properties
