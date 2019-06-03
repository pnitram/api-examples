package no.ohuen.sbanken;


import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Base64;

import static java.nio.charset.StandardCharsets.UTF_8;

/**
 *
 * @author Timur Samkharadze
 */
public class SbankenClient {

    private static final String IDENTITY_SERVER_URL = "https://auth.sbanken.no/identityserver/connect/token";
    private static final String ACCOUNT_SERVICE_URL = "https://api.sbanken.no/exec.bank/api/v1/accounts/";
    private final static Gson GSON = new GsonBuilder().setPrettyPrinting().create();

    /**
     * entry point
     *
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws IOException, URISyntaxException, InterruptedException {
        if (args.length != 3) {
            throw new RuntimeException("Usage: SbankenClient <clientId> <secret> <userId>");
        }
        String clientId = args[0];
        String secret = args[1];
        String userId = args[2];
        String basicAuth = getBase64AuthString(clientId, secret);
        var httpClient = HttpClient.newHttpClient();
        String token = getAccessToken(httpClient, basicAuth);
        String respStr = getAccountInfo(httpClient, userId, token);
        System.out.println(respStr);
    }

    private static String getAccountInfo(HttpClient httpClient, String userId, String token) throws IOException, URISyntaxException, InterruptedException {
        //now we have token and can qury sbanken api
        var serviceRequest = HttpRequest.newBuilder(new URI(ACCOUNT_SERVICE_URL))
                .header("Accept", "application/json")
                .header("Authorization", "Bearer " + token)
                .header("customerId", userId)
                .build();
        return  httpClient.send(serviceRequest, HttpResponse.BodyHandlers.ofString()).body();
    }

    private static String getBase64AuthString(String clientId, String secret) throws UnsupportedEncodingException {
        return new String(Base64.getEncoder().encode(String.format("%s:%s", URLEncoder.encode(clientId, UTF_8), URLEncoder.encode(secret, UTF_8)).getBytes(UTF_8)), UTF_8);
    }

    static String getAccessToken(HttpClient httpClient, String basicAuth) throws IOException, URISyntaxException, InterruptedException {
        var serviceRequest = HttpRequest.newBuilder(new URI(IDENTITY_SERVER_URL))
                .header("Accept", "application/json")
                .header("Authorization", "Basic " + basicAuth)
                .header("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
                .POST(HttpRequest.BodyPublishers.ofByteArray("grant_type=client_credentials".getBytes()))
                .build();
        var response = httpClient.send(serviceRequest, HttpResponse.BodyHandlers.ofString());
        return GSON.fromJson(response.body(), Token.class).access_token;
    }

    private static class Token {
        String access_token;
    }
}
