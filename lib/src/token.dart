part of directcode.services;

List<String> tokens;

class RequiresToken {
  const RequiresToken();
}

void TokenPlugin(Manager manager) {
  manager.addRouteWrapper(RequiresToken, (dynamic metadata, Map<String, String> pathSegments, injector, app.Request request, app.RouteHandler route) {
    var token = app.request.headers['X-DirectCode-Token'];

    if (token == null) {
      app.chain.interrupt(statusCode: HttpStatus.UNAUTHORIZED, responseValue: {
        "error": "token.required",
        "message": "A token is required to use this API."
      });
    } else if (!tokens.contains(token)) {
      app.chain.interrupt(statusCode: HttpStatus.UNAUTHORIZED, responseValue: {
        "error": "token.invalid",
        "message": "The token that was provided is invalid."
      });
    } else {
      app.chain.next();
    }
  }, includeGroups: true);
}

void loadTokens() {
  var file = new File("tokens.json");

  if (!file.existsSync()) {
    file.writeAsStringSync("[]");
  }

  var content = file.readAsStringSync();

  tokens = JSON.decode(content);
}
