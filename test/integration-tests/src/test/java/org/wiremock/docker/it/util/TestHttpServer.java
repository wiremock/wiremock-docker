package org.wiremock.docker.it.util;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class TestHttpServer {
    private final HttpServer server;
    private final AllRequestsRecorder handler;

    public static TestHttpServer newInstance() {
        try {
            return new TestHttpServer(0);
        } catch (IOException e) {
            throw new RuntimeException("Failed to start Test Http Server", e);
        }
    }

    private TestHttpServer(int port) throws IOException {
        // handlers
        handler = new AllRequestsRecorder();
        // server
        server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", handler);
        server.start();
    }

    public int getPort() {
        return server.getAddress().getPort();
    }

    public List<RecordedRequest> getRecordedRequests() {
        return handler.getRecordedRequests();
    }


    private static final class AllRequestsRecorder implements HttpHandler {

        private final List<RecordedRequest> recordedRequests = new ArrayList<>();

        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String method = exchange.getRequestMethod();
            String path = exchange.getRequestURI().getPath();
            String body = null;

            InputStream requestBody = exchange.getRequestBody();
            if (requestBody.available() > 0) {
                byte[] requestBodyBytes = new byte[requestBody.available()];
                requestBody.read(requestBodyBytes);
                body = new String(requestBodyBytes, StandardCharsets.UTF_8);
            }

            recordedRequests.add(new RecordedRequest(method, path, body));

            exchange.sendResponseHeaders(200, 0);
            exchange.getResponseBody().close();
        }

        public List<RecordedRequest> getRecordedRequests() {
            return recordedRequests;
        }
    }

    public static final class RecordedRequest {
        private final String method;
        private final String path;
        private final String body;

        public RecordedRequest(String method, String path, String body) {
            this.method = method;
            this.path = path;
            this.body = body;
        }

        public String getMethod() {
            return method;
        }

        public String getPath() {
            return path;
        }

        public String getBody() {
            return body;
        }

        @Override
        public String toString() {
            return "RecordedRequest{" +
                    "method='" + method + '\'' +
                    ", path='" + path + '\'' +
                    ", body='" + body + '\'' +
                    '}';
        }

    }
}
