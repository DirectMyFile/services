library directcode.services.common;

import "dart:io";
import "dart:convert" show JSON;

import "package:mustache4dart/mustache4dart.dart";

import "package:redstone/server.dart" as app;

import "package:http/http.dart" as http;

import "package:redstone/server.dart" show
  Route, Group, Attr, Interceptor, QueryParam, ErrorHandler, DefaultRoute, Body, GET, POST, PUT, DELETE, ErrorResponse, RedstonePlugin, Manager;

export 'package:redstone_mapper/mapper.dart';
export 'package:redstone_mapper/plugin.dart';
export 'package:redstone_mapper_mongo/service.dart';
export 'package:redstone_mapper_mongo/manager.dart';
export 'package:redstone_mapper_mongo/metadata.dart';
export 'package:redstone_web_socket/redstone_web_socket.dart';

export "package:redstone/server.dart" show
  Route, Group, Attr, Interceptor, QueryParam, ErrorHandler, DefaultRoute, Body, GET, POST, PUT, DELETE, ErrorResponse, RedstonePlugin, Manager, request, response, Install, Inject, Ignore, chain, JSON, FORM;

bool useTokenFile = true;
List<String> tokens;


http.Client httpClient = new http.Client();

Map<String, dynamic> config;

class RequiresToken {
  const RequiresToken();
}

String template(String templateName, Map binding) {
  var file = new File("templates/${templateName}.mustache");
  
  if (!file.existsSync()) {
    throw new ArgumentError("Template does not exist.");
  }
  
  return render(file.readAsStringSync(), binding);
}

File www(String path) => new File("www/${path}");

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
      return route(pathSegments, injector, request);
    }
  }, includeGroups: true);
}

void loadConfig() {
  var file = new File("config.json");

  if (!file.existsSync()) {
    file.writeAsStringSync("{}");
  }

  var content = file.readAsStringSync();

  config = JSON.decode(content);
}

void loadTokens() {
  if (useTokenFile) {
    var file = new File("tokens.json");

    if (!file.existsSync()) {
      file.writeAsStringSync("[]");
    }

    var content = file.readAsStringSync();

    tokens = JSON.decode(content);
  } else {
    tokens = [];
  }
}
