package org.wiremock.docker.it.util;

public class HttpResponse {

    String body;
    int statusCode;
    public HttpResponse(String body, int statusCode) {
        this.body = body;
        this.statusCode = statusCode;
    }

    public String getBody() {
        return body;
    }

    public int getStatusCode() {
        return statusCode;
    }
}
