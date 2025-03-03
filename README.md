# WireMock Docker images

[![Main](https://github.com/wiremock/wiremock-docker/actions/workflows/main.yml/badge.svg)](https://github.com/wiremock/wiremock-docker/actions/workflows/main.yml) [![Nightly](https://github.com/wiremock/wiremock-docker/actions/workflows/nightly.yml/badge.svg)](https://github.com/wiremock/wiremock-docker/actions/workflows/nightly.yml) [![Docker Pulls](https://img.shields.io/docker/pulls/wiremock/wiremock.svg)](https://hub.docker.com/r/wiremock/wiremock/)
[![a](https://img.shields.io/badge/slack-Join%20us-brightgreen?style=flat&logo=slack)](https://slack.wiremock.org/)

The official Docker image for WireMock Standalone deployments.
It includes WireMock for Java under the hood, and fully compatible with its features.
You can learn more about WireMock standalone on the
[WireMock docs site]((http://wiremock.org/docs/standalone)).

## Quick Start

In a temporary directory, checkout the demo repository,
pull the Docker image,
and start the WireMock instance.

```shell
docker pull wiremock/wiremock:latest
git clone https://github.com/wiremock/wiremock-docker.git
docker run -it --rm \
  -p 8080:8080 \
  -v $PWD/wiremock-docker/samples/hello/stubs:/home/wiremock \
  wiremock/wiremock:latest
```

You will get a CLI output like this one:

```shell
██     ██ ██ ██████  ███████ ███    ███  ██████   ██████ ██   ██
██     ██ ██ ██   ██ ██      ████  ████ ██    ██ ██      ██  ██
██  █  ██ ██ ██████  █████   ██ ████ ██ ██    ██ ██      █████
██ ███ ██ ██ ██   ██ ██      ██  ██  ██ ██    ██ ██      ██  ██
 ███ ███  ██ ██   ██ ███████ ██      ██  ██████   ██████ ██   ██

----------------------------------------------------------------
|               Cloud: https://wiremock.io/cloud               |
|               Slack: https://slack.wiremock.org              |
----------------------------------------------------------------

port:                         8080
enable-browser-proxying:      false
no-request-journal:           false
verbose:                      false
extensions:                   response-template,webhook
```

## Supported architectures

- x64
- armv7
- armv8

## Supported tags

There are multiple image tags provided for end users.
These tags are available on DockerHub and GitHub Packages,
see the full list [here](https://hub.docker.com/r/wiremock/wiremock/tags/).
The most important tags are listed below.

### Latest images

- `3.12.1-1` [(3.12.1-1/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/3.12.1-1/Dockerfile)
- `3.12.1-1-alpine` [(3.12-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/3.12.1-1/alpine/Dockerfile)
- `latest` [(latest/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/latest/Dockerfile)
- `latest-alpine` [(latest-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/latest-alpine/Dockerfile)
- `main` [(main/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/main/Dockerfile)
- `main-alpine` [(main-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/main/alpine/Dockerfile)

### Latest WireMock 2.x images

- `2.35.1-1` [(2.35.1-1/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/2.35.1-1/Dockerfile)
- `2.35.1-1-alpine` [(2.35.1-1-alpine/Dockerfile)](https://github.com/wiremock/wiremock-docker/blob/2.35.1-1/alpine/Dockerfile)

### Deprecated and experimental tags

- `nightly` [(main/Dockerfile-nightly)](https://github.com/wiremock/wiremock-docker/blob/main/Dockerfile-nightly)
- `nightly-alpine` [(main-alpine/Dockerfile-nightly)](https://github.com/wiremock/wiremock-docker/blob/main/alpine/Dockerfile-nightly)
- `3x`- Latest WireMock 3.x image, with bundled Java 11 - now `latest`
- `3x-alpine` - Latest WireMock alpine 3.x image, with bundled Java 11 - now `latest`

## Using WireMock in Docker

To start WireMock with the default settings:

```sh
docker run -it --rm -p 8080:8080 wiremock/wiremock
```

By default, the image exposes the 8080 port for HTTP.
To verify the WireMock state,
access [http://localhost:8080/__admin/health](http://localhost:8080/__admin/health) to display the health status and the information.
The `/__admin/health` endpoint is available for WireMock 3.1.0 or above.

A [HEALTHCHECK](https://docs.docker.com/reference/dockerfile/#healthcheck) is also built into the docker image to
allow direct querying of the docker container's health status.
Under the hood, this uses the same method as above to verify the status of the container.

## Configuring WireMock

You can configure WireMock using the following ways:

- Passing the CLI arguments
- Passing Environment variables
- Passing configuration files via volumes
- Building a custom image using `wiremock/wiremock` as a base image

### Passing the CLI arguments

To start with these WireMock arguments,
you can add them to the end of the command line.
For example, to enable HTTPs: `--https-port 8443 --verbose`

```sh
docker run -it --rm -p 8443.12443 wiremock/wiremock --https-port 8443 --verbose
```

### Using environment variables

The following environment variables are supported by the image:

- `uid` : the container executor uid, useful to avoid file creation owned by root
- `JAVA_OPTS` : for passing any custom options to Java e.g. `-Xmx128m`
- `WIREMOCK_OPTIONS`: CLI options to be passed to WireMock (starting from `3.2.0-2`).

Example for passing the CLI options:

```sh
docker run -it --rm \
  -e WIREMOCK_OPTIONS='--https-port 8443 --verbose' \
  -p 8443.12443 \
  --name wiremock \
  wiremock/wiremock:latest
```

### Passing configuration files as volumes

Inside the container, the WireMock uses `/home/wiremock` as the root from which it reads the `mappings` and `__files` directories.
This means you can mount a directory containing these from your host machine into Docker and WireMock will load the stub mappings.

To mount the current directory use `-v $PWD:/home/wiremock` e.g.:

```sh
docker run -it --rm \
  -p 8080:8080 \
  --name wiremock \
  -v $PWD:/home/wiremock \
  wiremock/wiremock:{{ site.wiremock_version }}
```

## Building your own image

Inside the container, the WireMock uses `/home/wiremock` as the root from which it reads the `mappings` and `__files` directories.
This means you can copy your configuration from your host machine into Docker and WireMock will load the stub mappings.

WireMock utilizes a custom entrypoint script that passes all provided arguments as WireMock startup parameters. To modify the WireMock launch parameters it is recommended to override the entrypoint in your custom Docker image. 

```Dockerfile
# Sample Dockerfile
FROM wiremock/wiremock:latest
COPY wiremock /home/wiremock
ENTRYPOINT ["/docker-entrypoint.sh", "--global-response-templating", "--disable-gzip", "--verbose"]
```

## Using WireMock extensions

You can use any [WireMock extension](https://wiremock.org/docs/extensions)
with the Docker image.
They can be added via CLI and volumes,
but for most of the use-cases it is recommended to build a custom image by extending the
official one.

### Using extensions in CLI

For old style extensions (that don't have Java service loader metadata) you need to add the extension JAR file into the extensions directory and
specify the name of the extension's main class via the `--extensions` parameter:

```sh
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

For new style extensions the `--extensions` part should not be included as the extension will be discovered and loaded automatically:

```sh
# prepare extension folder
mkdir wiremock-docker/samples/random/extensions
# download extension
wget https://repo1.maven.org/maven2/org/wiremock/wiremock-grpc-extension-standalone/0.5.0/wiremock-grpc-extension-standalone-0.5.0.jar \
  -O wiremock-docker/samples/random/extensions/wiremock-grpc-extension-standalone-0.5.0.jar
# run a container using extension 
docker run -it --rm \
  -p 8080:8080 \
  -v $PWD/wiremock-docker/samples/random/stubs:/home/wiremock \
  -v $PWD/wiremock-docker/samples/random/extensions:/var/wiremock/extensions \
  wiremock/wiremock
```

### Using extensions in the Dockerfile

```sh
git clone https://github.com/wiremock/wiremock-docker.git
docker build -t wiremock-random wiremock-docker/samples/random
docker run -it --rm -p 8080:8080 wiremock-random
```

> Access [http://localhost:8080/random](http://localhost:8080/random) to show random number

## Advanced use-cases

### Using HTTPs

For HTTPs, the `8443` port is exposed by default.
To run with HTTPs, run the following command:

```sh
docker run -it --rm -p 8443.12443 wiremock/wiremock --https-port 8443 --verbose
```

To check the HTTPs on the default exposed port,
use [https://localhost:8443/__admin](https://localhost:8443/__admin) to check HTTPs working.

### Using the Record Mode

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

### Docker Compose

Configuration in compose file is similar to Dockerfile definition

```yaml
# Sample compose file
version: "3"
services:
  wiremock:
    image: "wiremock/wiremock:latest"
    container_name: my_wiremock
    entrypoint: ["/docker-entrypoint.sh", "--global-response-templating", "--disable-gzip", "--verbose"]
```

You can also mount your local `__files` and `mappings` files into the container e.g:

```yaml
# Sample compose file
version: "3"
services:
  wiremock:
    image: "wiremock/wiremock:latest"
    container_name: my_wiremock
    volumes:
      - ./__files:/home/wiremock/__files
      - ./mappings:/home/wiremock/mappings
    entrypoint: ["/docker-entrypoint.sh", "--global-response-templating", "--disable-gzip", "--verbose"]
```

## References

- [WireMock modules for Testcontainers](https://wiremock.org/docs/solutions/testcontainers/), based on this official image
- [Helm Chart for WireMock](https://wiremock.org/docs/solutions/kubernetes/)
