# Wiremock Docker
[![Main](https://github.com/wiremock/wiremock-docker/actions/workflows/main.yml/badge.svg)](https://github.com/wiremock/wiremock-docker/actions/workflows/main.yml) [![Nightly](https://github.com/wiremock/wiremock-docker/actions/workflows/nightly.yml/badge.svg)](https://github.com/wiremock/wiremock-docker/actions/workflows/nightly.yml) [![Docker Pulls](https://img.shields.io/docker/pulls/wiremock/wiremock.svg)](https://hub.docker.com/r/wiremock/wiremock/)
[![a](https://img.shields.io/badge/slack-Join%20us-brightgreen?style=flat&logo=slack)](https://slack.wiremock.org/)

> [WireMock](http://wiremock.org) Standalone server Docker image

## Supported tags

### Latest images

- `3.3.1-1` [(3.3.1-1/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/3.3.1-1/Dockerfile)
- `3.3.1-1-alpine` [(3.3-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/3.3.1-1/alpine/Dockerfile)
- `latest` [(latest/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/latest/Dockerfile)
- `latest-alpine` [(latest-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/latest-alpine/Dockerfile)
- `main` [(main/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/main/Dockerfile)
- `main-alpine` [(main-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/main/alpine/Dockerfile)
- `nightly` [(main/Dockerfile-nightly)](https://github.com/wiremock/wiremock-docker/blob/main/Dockerfile-nightly)
- `nightly-alpine` [(main-alpine/Dockerfile-nightly)](https://github.com/wiremock/wiremock-docker/blob/main/alpine/Dockerfile-nightly)

### Latest WireMock 2.x images

- `3.3.1-1` [(3.3/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/3.3.1-1/Dockerfile)
- `3.3.1-1-alpine` [(3.3-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/3.3.1-1/alpine/Dockerfile)

### Deprecated tags

- `3x`- Latest WireMock 3.x image, with bundled Java 11 - now `latest`
- `3x-alpine` - Latest WireMock alpine 3.x image, with bundled Java 11 - now `latest`

### Complete list

[Tags](https://hub.docker.com/r/wiremock/wiremock/tags/)

## Supported architectures

- x64
- armv7
- armv8

## The image includes

- `EXPOSE 8080 8443` : the wiremock http/https server port

## How to use this image

#### Environment variables

- `uid` : the container executor uid, useful to avoid file creation owned by root
- `JAVA_OPTS` : for passing any custom options to Java e.g. `-Xmx128m`

#### Getting started

##### Pull latest image

```sh
docker pull wiremock/wiremock
```

##### Start a Wiremock container

```sh
docker run -it --rm -p 8080:8080 wiremock/wiremock
```

> Access [http://localhost:8080/__admin](http://localhost:8080/__admin) to display the mappings (empty set)

##### Start a Wiremock container with Wiremock arguments

To start with these Wiremock arguments : `--https-port 8443 --verbose`

```sh
docker run -it --rm -p 8443:8443 wiremock/wiremock --https-port 8443 --verbose
```

> Access [https://localhost:8443/__admin](https://localhost:8443/__admin) to check https working

##### Start record mode using host uid for file creation

In Record mode, when binding host folders (e.g. $PWD/test) with the container volume (/home/wiremock), the created files will be owned by root, which is, in most cases, undesired.
To avoid this, you can use the `uid` docker environment variable to also bind host uid with the container executor uid.

```sh
docker run -d --name wiremock-container \
  -p 8080:8080 \
  -v $PWD/test:/home/wiremock \
  -e uid=$(id -u) \
  wiremock/wiremock \
    --proxy-all="http://registry.hub.docker.com" \
    --record-mappings --verbose
curl http://localhost:8080
docker rm -f wiremock-container
```

> Check the created file owner with `ls -alR test`

However, the example above is a facility. 
The good practice is to create yourself the binded folder with correct permissions and to use the *-u* docker argument.

```sh
mkdir test
docker run -d --name wiremock-container \
  -p 8080:8080 \
  -v $PWD/test:/home/wiremock \
  -u $(id -u):$(id -g) \
  wiremock/wiremock \
    --proxy-all="http://registry.hub.docker.com" \
    --record-mappings --verbose
curl http://localhost:8080
docker rm -f wiremock-container
```

> Check the created file owner with `ls -alR test`
 
#### Samples

##### Start a Hello World container

###### Inline

```sh
git clone https://github.com/wiremock/wiremock-docker.git
docker run -it --rm \
  -p 8080:8080 \
  -v $PWD/wiremock-docker/samples/hello/stubs:/home/wiremock \
  wiremock/wiremock
```

###### Dockerfile

```sh
git clone https://github.com/wiremock/wiremock-docker.git
docker build -t wiremock-hello wiremock-docker/samples/hello
docker run -it --rm -p 8080:8080 wiremock-hello
```

> Access [http://localhost:8080/hello](http://localhost:8080/hello) to show Hello World message

##### Use wiremock extensions

###### Inline

```sh
git clone https://github.com/wiremock/wiremock-docker.git
# prepare extension folder
mkdir wiremock-docker/samples/random/extensions
# download extension
wget https://repo1.maven.org/maven2/com/opentable/wiremock-body-transformer/1.1.3/wiremock-body-transformer-1.1.3.jar \
  -O wiremock-docker/samples/random/extensions/wiremock-body-transformer-1.1.3.jar
# run a container using extension 
docker run -it --rm \
  -p 8080:8080 \
  -v $PWD/wiremock-docker/samples/random/stubs:/home/wiremock \
  -v $PWD/wiremock-docker/samples/random/extensions:/var/wiremock/extensions \
  wiremock/wiremock \
    --extensions com.opentable.extension.BodyTransformer
```

###### Dockerfile

```sh
git clone https://github.com/wiremock/wiremock-docker.git
docker build -t wiremock-random wiremock-docker/samples/random
docker run -it --rm -p 8080:8080 wiremock-random
```

> Access [http://localhost:8080/random](http://localhost:8080/random) to show random number
