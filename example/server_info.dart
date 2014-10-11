import "common.dart";

void main() {
  var endpoint = new APIEndpoint<Map<String, dynamic>>("/internal/server");

  endpoint.get().then((response) {
    print(response);
  });
}
