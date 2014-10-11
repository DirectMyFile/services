import "package:http/http.dart" as http;

import "dart:io";
import "dart:convert";
import "dart:async";

String BASE_URL = "http://127.0.0.1:8080/api";

String TOKEN = "examples";

final http.Client client = new http.Client();

class APIEndpoint<T> {
  final String path;

  APIEndpoint(this.path);

  Future<T> get() {
    return client.get(Uri.parse(BASE_URL + path), headers: {
      "X-DirectCode-Token": TOKEN
    }).then((response) {
      return JSON.decode(response.body);
    }).then((data) {
      client.close();
      return data;
    });
  }
}
