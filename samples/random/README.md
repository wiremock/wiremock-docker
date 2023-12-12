# Sample - Random Response Field

We use WireMock Faker extension in this demo:

To run:

```shell
docker build -t wiremock/random-data-demo .
docker run --rm - p 8080:8080 wiremock/random-data-demo
```

Then you can use the following endpoints:

- '/user' - random user ID
- '/user?pretty=true' - random user id with fancy layout
- '/users.csv' - generate a CSV file with a random number of users
