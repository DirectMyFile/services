part of directcode.services.common;

bool useTokenFile = true;
Multimap<String, String> tokens;

class RequiresToken {
  final List<String> permissions;

  const RequiresToken({this.permissions: const []});
}

void TokenPlugin(Manager manager) {
  manager.addRouteWrapper(RequiresToken, (dynamic metadata, Map<String, String> pathSegments, injector, app.Request request, app.RouteHandler route) {
    var token = app.request.headers['X-DirectCode-Token'];
    var info = metadata as RequiresToken;

    if (token == null) {
      app.chain.interrupt(statusCode: HttpStatus.UNAUTHORIZED, responseValue: {
          "error": "token.required",
          "message": "A token is required to use this API."
      });
    } else if (!tokens.containsKey(token)) {
      app.chain.interrupt(statusCode: HttpStatus.UNAUTHORIZED, responseValue: {
          "error": "token.invalid",
          "message": "The token that was provided is invalid."
      });
    } else if (!hasPermissions(token, info.permissions)) {
      app.chain.interrupt(statusCode: HttpStatus.UNAUTHORIZED, responseValue: {
          "error": "token.permission.missing",
          "message": "The token that was provided does not have the required permissions to use this API."
      });
    } else {
      return route(pathSegments, injector, request);
    }
  }, includeGroups: true);
}

void loadTokens() {
  if (useTokenFile) {
    var file = new File("tokens.json");

    if (!file.existsSync()) {
      file.writeAsStringSync("{}");
    }

    var content = file.readAsStringSync();

    var map = JSON.decode(content);

    tokens = new Multimap<String, String>();

    for (var key in map.keys) {
      tokens.addValues(key, map[key]);
    }
  } else {
    tokens = new Multimap();
  }
}

bool hasPermissions(String token, List<String> perms) =>
perms.any((perm) => hasPermission(token, perm));

bool hasPermission(String token, String perm) {
  var allPerms = tokens[token];

  if (allPerms.contains("*")) {
    return true;
  }

  var parts = perm.split(".");

  var builder = new StringBuffer();

  var previous = [];

  for (var part in parts) {
    builder
      ..writeAll(previous, ".")
      ..write(".")
      ..write(part);
    previous.add(part);

    var perm = builder.toString();

    if (allPerms.contains(perm) || allPerms.contains(perm + ".*")) {
      return true;
    }

    builder.clear();
  }

  return false;
}