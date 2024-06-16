package com.kube.rodo;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.io.BufferedReader;
import java.io.InputStreamReader;
public class HelloRodo {
    public static void main(String[] args) throws Exception {
        // Start the HTTP server in a new thread
        Thread httpThread = new Thread(() -> {
            try {
                startHttpServer();
            } catch (Exception e) {
                System.err.println("Error starting HTTP server: " + e.getMessage());
            }
        });

        // Start the TCP server in a new thread
        Thread tcpThread = new Thread(() -> {
            try {
                startTcpServer();
            } catch (Exception e) {
                System.err.println("Error starting TCP server: " + e.getMessage());
            }
        });

        // Start both threads
        httpThread.start();
        tcpThread.start();

        // Wait for both threads to finish
        httpThread.join();
        tcpThread.join();
    }

    // Method to start the HTTP server
    public static void startHttpServer() throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/", new MyHandler());
        server.start();
        System.out.println("HTTP server listening on port 8080");
    }

    // Class to handle HTTP requests
    static class MyHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String response = "Hello World! v2\n";
            exchange.sendResponseHeaders(200, response.getBytes().length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }

    // Method to start the TCP server
    public static void startTcpServer() throws Exception {
        int port = 9000; // Port where the server will listen

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("TCP server listening on port " + port);

            while (true) {
                try (Socket clientSocket = serverSocket.accept()) {
                    System.out.println("Client connected: " + clientSocket.getInetAddress());

                    // Read the client's message
                    BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                    String clientMessage = in.readLine();
                    System.out.println("Client message: " + clientMessage);

                    // Send a response to the client
                    PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
                    String response = "Message received: " + clientMessage;
                    out.println(response);
                } catch (IOException e) {
                    System.out.println("Error handling client connection: " + e.getMessage());
                }
            }
        } catch (IOException e) {
            System.out.println("Error starting TCP server: " + e.getMessage());
        }
    }
}
