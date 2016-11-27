# Wiremock Docker

> [Wiremock](http://wiremock.org) standalone HTTP server Docker image

## Supported tags & respective Dockerfile links :

- `2.4.1`, `latest` [(2.4/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.4.1/Dockerfile)
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

##### Start a Wiremock container

```sh
docker run -it --rm -p 8080:8080 rodolpheche/wiremock
```

> Access [http://localhost:8080/__admin](http://localhost:8080/__admin) to display the mappings (empty set)

##### Start a Hello World container

```sh
git clone https://github.com/rodolpheche/wiremock-docker.git
docker run -it --rm -v $PWD/wiremock-docker/sample:/home/wiremock -p 8080:8080 rodolpheche/wiremock
```

> Access [http://localhost:8080/hello](http://localhost:8080/hello) to show Hello World message

##### Start a Wiremock container with Wiremock arguments

**!! WARNING !!** WIREMOCK_ARGS environment variable is now deprecated, it will be removed in a future version

```sh
# !! DEPRECATED !!
docker run -it --rm -p 8081:8081 -e WIREMOCK_ARGS="--https-port 8081" rodolpheche/wiremock
# !! DEPRECATED !!
```

Instead, you should now use docker container arguments :

```sh
docker run -it --rm -p 8081:8081 rodolpheche/wiremock --https-port 8081 --verbose
```

> Access [https://localhost:8081/__admin](https://localhost:8081/__admin) to to check https working

##### Start a Bash session from a container

```sh
docker run -d -p 8080:8080 --name rodolpheche-wiremock-container rodolpheche/wiremock
docker exec -it rodolpheche-wiremock-container bash
echo $WIREMOCK_VERSION
exit # exit container
docker rm -f rodolpheche-wiremock-container
```



##### Start record mode using host uid for file creation

In Record mode, when binding host folders (ex. $PWD/test) with the container volume (/home/wiremock), the created files will be owned by root, which is, in most cases, undesired.
To avoid this, you can use the `uid` docker environment variable to also bind host uid with the container executor uid.

```sh
docker run -d -p 8080:8080 --name rodolpheche-wiremock-container -v $PWD/test:/home/wiremock -e uid=$(id -u) rodolpheche/wiremock --proxy-all="http://registry.hub.docker.com" --record-mappings --verbose
curl http://localhost:8080
docker rm -f rodolpheche-wiremock-container
```

> Check the created file owner with `ls -alR test`
 
