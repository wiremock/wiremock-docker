# Wiremock Docker

> [Wiremock](http://wiremock.org) standalone HTTP server Docker image

## Supported tags and respective Dockerfile links :

- `2.0.6-beta`, `latest` [(2.0/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.0.6-beta/Dockerfile)

## How to use this image

##### The image include 

- `EXPOSE 8080 443` : the wiremock http/https server port.
- `VOLUME /home/wiremock` : the wiremock data storage.

##### Launch a Wiremock container

```sh
$ mkdir stub
$ docker run -d -v $PWD/stub:/home/wiremock -p 8080:8080 rodolpheche/wiremock
```

> Simply access [http://localhost:8080/__admin](http://localhost:8080/__admin) to check your mappings

##### Launch a Hello World container

```sh
$ git clone https://github.com/rodolpheche/wiremock-docker.git
$ docker run -d -v $PWD/wiremock-docker/stub:/home/wiremock -p 8080:8080 rodolpheche/wiremock
```

> Access [http://localhost:8080/hello](http://localhost:8080/hello) to show Hello World message

##### Launch a Wiremock container with Wiremock arguments

```sh
$ docker run -d -v $PWD/stub:/home/wiremock -p 8080:8080 -e WIREMOCK_ARGS="--verbose" rodolpheche/wiremock
```

##### Stop the container with Wiremock HTTP API

```sh
$ curl -XPOST http://localhost:8080/__admin/shutdown
```
