# Wiremock Docker

> [Wiremock](http://wiremock.org) standalone HTTP server Docker image

## Supported tags and respective Dockerfile links :

- `2.0.10-beta`, `latest` [(2.0/Dockerfile)](https://github.com/rodolpheche/wiremock-docker/blob/2.0.10-beta/Dockerfile)

## How to use this image

##### The image include 

- `EXPOSE 8080 8081` : the wiremock http/https server port
- `VOLUME /home/wiremock` : the wiremock data storage

##### Launch a Wiremock container

```sh
mkdir stub
docker run -d -v $PWD/stub:/home/wiremock -p 8080:8080 rodolpheche/wiremock
```

> Simply access [http://localhost:8080/__admin](http://localhost:8080/__admin) to display your mappings (empty set)

##### Launch a Hello World container

```sh
git clone https://github.com/rodolpheche/wiremock-docker.git
docker run -d -v $PWD/wiremock-docker/sample/stub:/home/wiremock -p 8080:8080 rodolpheche/wiremock
```

> Access [http://localhost:8080/hello](http://localhost:8080/hello) to show Hello World message

##### Launch a Wiremock container with Wiremock arguments

```sh
docker run -d -v $PWD/stub:/home/wiremock -p 8080:8080 -p 8081:8081 -e WIREMOCK_ARGS="--verbose --https-port 8081" rodolpheche/wiremock
```

> Access [https://localhost/__admin](https://localhost/__admin) to to check https working
