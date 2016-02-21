#!/bin/bash

MAJOR_LATEST_VERSION=$(echo $LATEST_VERSION | cut -f1 -d".")
MAJOR_VERSION=$(echo $VERSION | cut -f1 -d".")

# change wiremock version
if [[ $MAJOR_LATEST_VERSION == $MAJOR_VERSION ]]
then
  sed -i "s/$VERSION/$LATEST_VERSION/g" readme.md
else
  # todo
  sed -i "s/$VERSION/$LATEST_VERSION/g" readme.md
fi
sed -i "s/ENV WIREMOCK_VERSION\(.*\)/ENV WIREMOCK_VERSION $LATEST_VERSION/" Dockerfile
sed -i "s/^VERSION=.*/VERSION=$LATEST_VERSION/" version.properties


# commit change
git config --global user.name "rodolpheche"
git config --global user.email rodolphe.chaigneau@gmail.com
git add Dockerfile readme.md version.properties
git commit -m "upgrade version to $LATEST_VERSION"
