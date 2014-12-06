part of directcode.services.common;

bool useTokenFile = true;
Multimap<String, String> tokens;

class RequiresToken {
  final List<String> permissions;

  const RequiresToken({this.permissions: const []});
}

@Plugin
void TokenPlugin(Manager manager) {
  manager.addRouteWrapper(RequiresToken, (dynamic metadata, Map<String, String> pathSegments, injector, app.Request request, app.RouteHandler route) {
    var token = app.request.headers['X-DirectCode-Token'];
    if (token == null) token = app.request.queryParams["token"];
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

@Setup
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

bool hasPermissions(String token, List<String> perms) => perms.any((perm) => hasPermission(token, perm));

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

String generateToken({int length: 50}) {
  Random r = new Random();
  var buffer = new StringBuffer();
  for (int i = 1; i <= length; i++) {
    if (r.nextBool()) {
      String letter = alphabet[random.nextInt(alphabet.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else {
      buffer.write(numbers[r.nextInt(numbers.length)]);
    }
  }
  return buffer.toString();
}

class TokenManager {
  Map<String, List<String>> allTokens = {};

  TokenManager();

  void load({String path: "tokens.json"}) {
    var file = new File(path);
    var data = file.readAsStringSync();
    allTokens = JSON.decode(data);
  }

  void addToken(String token, {List<String> permissions: const []}) {
    allTokens[token] = permissions;
  }

  void removeToken(String token) {
    allTokens.remove(token);
  }

  void addPermission(String token, String permission) {
    allTokens[token].add(permission);
  }

  void removePermission(String token, String permission) {
    allTokens[token].remove(permission);
  }

  void save({String path: "tokens.json"}) {
    var file = new File(path);
    file.writeAsStringSync(new Convert.JsonEncoder.withIndent("  ").convert(allTokens));
  }
}

const List<String> alphabet = const ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
const List<int> numbers = const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
