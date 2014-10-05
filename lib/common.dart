library directcode.services.common;

import "dart:io";
import "dart:convert" show JSON;

import "package:redstone/server.dart" as app;

import "package:redstone/server.dart" show
  Route, Group, Attr, Interceptor, QueryParam, ErrorHandler, DefaultRoute, Body, GET, POST, PUT, DELETE, ErrorResponse, RedstonePlugin, Manager;

export 'package:redstone_mapper/mapper.dart';
export 'package:redstone_mapper/plugin.dart';
export 'package:redstone_mapper_mongo/service.dart';
export 'package:redstone_mapper_mongo/manager.dart';
export 'package:redstone_mapper_mongo/metadata.dart';

export "package:redstone/server.dart" show
  Route, Group, Attr, Interceptor, QueryParam, ErrorHandler, DefaultRoute, Body, GET, POST, PUT, DELETE, ErrorResponse, RedstonePlugin, Manager, request, response, Install, Inject, Ignore, chain, JSON, FORM;

bool useTokenFile = true;
List<String> tokens;

Map<String, dynamic> config;

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
