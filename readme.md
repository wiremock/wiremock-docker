# Wiremock Docker

> [Wiremock](http://wiremock.org) standalone HTTP server Docker image

## Supported tags & respective Dockerfile links :

- `2.6.0`, `latest` [(latest/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.6.0/Dockerfile)
- `2.6.0-alpine` [(2.6-alpine/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.6.0/alpine/Dockerfile)
- `2.5.1` [(2.5/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.5.1/Dockerfile)
- `2.4.1` [(2.4/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.4.1/Dockerfile)
- `2.3.1` [(2.3/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.3.1/Dockerfile)
- `2.2.2` [(2.2/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.2.2/Dockerfile)
- `2.1.12` [(2.1/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.1.12/Dockerfile)

## The image includes

- `EXPOSE 8080 8081` : the wiremock http/https server port
- `VOLUME /home/wiremock` : the wiremock data storage

## How to use this image

#### Environment variables

- `uid` : the container executor uid, useful to avoid file creation owned by root

#### Getting started

##### Pull latest image

```sh
docker pull rodolpheche/wiremock
```

##### Start a Wiremock container

```sh
docker run -it --rm -p 8080:8080 rodolpheche/wiremock
```

> Access [http://localhost:8080/__admin](http://localhost:8080/__admin) to display the mappings (empty set)

##### Start a Wiremock container with Wiremock arguments

```sh
docker run -it --rm -p 8081:8081 rodolpheche/wiremock --https-port 8081 --verbose
```

> Access [https://localhost:8081/__admin](https://localhost:8081/__admin) to check https working

##### Start record mode using host uid for file creation

In Record mode, when binding host folders (ex. $PWD/test) with the container volume (/home/wiremock), the created files will be owned by root, which is, in most cases, undesired.
To avoid this, you can use the `uid` docker environment variable to also bind host uid with the container executor uid.

```sh
docker run -d --name rodolpheche-wiremock-container \
  -p 8080:8080 \
  -v $PWD/test:/home/wiremock \
  -e uid=$(id -u) \
  rodolpheche/wiremock \
    --proxy-all="http://registry.hub.docker.com" \
    --record-mappings --verbose
curl http://localhost:8080
docker rm -f rodolpheche-wiremock-container
```

> Check the created file owner with `ls -alR test`
 
#### Samples

##### Start a Hello World container

###### Inline

```sh
git clone https://github.com/rodolpheche/wiremock-docker.git
docker run -it --rm \
  -p 8080:8080 \
  -v $PWD/wiremock-docker/samples/hello/stubs:/home/wiremock \
  rodolpheche/wiremock
```

###### Dockerfile

```sh
git clone https://github.com/rodolpheche/wiremock-docker.git
docker build -t wiremock-hello wiremock-docker/samples/hello
docker run -it --rm -p 8080:8080 wiremock-hello
```

> Access [http://localhost:8080/hello](http://localhost:8080/hello) to show Hello World message

##### Use wiremock extensions

###### Inline

```sh
git clone https://github.com/rodolpheche/wiremock-docker.git
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
  rodolpheche/wiremock \
    --extensions com.opentable.extension.BodyTransformer
```

###### Dockerfile

```sh
git clone https://github.com/rodolpheche/wiremock-docker.git
docker build -t wiremock-random wiremock-docker/samples/random
docker run -it --rm -p 8080:8080 wiremock-random
```

> Access [http://localhost:8080/random](http://localhost:8080/random) to show random number

