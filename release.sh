#!/bin/bash

if [ ! $VERSION ]
then
  VERSION=$(curl -s http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/maven-metadata.xml | grep '<latest' | cut -f2 -d">" | cut -f1 -d"<")
fi
PREVIOUS_VERSION=$(cat Dockerfile | grep "ENV WIREMOCK_VERSION" | cut -f3 -d" ")


MAJOR_VERSION=$(echo $VERSION | cut -f1 -d".")
MAJOR_PREVIOUS_VERSION=$(echo $PREVIOUS_VERSION | cut -f1 -d".")

echo VERSION = $VERSION
echo PREVIOUS_VERSION = $PREVIOUS_VERSION

echo MAJOR_VERSION = $MAJOR_VERSION
echo MAJOR_PREVIOUS_VERSION = $MAJOR_PREVIOUS_VERSION

# change wiremock version
if [[ $MAJOR_VERSION == $MAJOR_PREVIOUS_VERSION ]]
then
  sed -i "s/$PREVIOUS_VERSION/$VERSION/g" readme.md
else
  # todo
  sed -i "s/$PREVIOUS_VERSION/$VERSION/g" readme.md
fi
sed -i "s/ENV WIREMOCK_VERSION\(.*\)/ENV WIREMOCK_VERSION $VERSION/" Dockerfile

# commit change
git add Dockerfile readme.md
git commit -m "upgrade version to $VERSION"
