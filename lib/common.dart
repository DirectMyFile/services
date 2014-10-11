library directcode.services.common;

import "dart:io";
import "dart:convert" show JSON;

import "package:mustache4dart/mustache4dart.dart";

import "package:redstone/server.dart" as app;

import "package:http/http.dart" as http;

import "dart:math" show Random;

import "package:redstone/server.dart" show
  Route, Group, Attr, Interceptor, QueryParam, ErrorHandler, DefaultRoute, Body, GET, POST, PUT, DELETE, ErrorResponse, RedstonePlugin, Manager;

import "package:logging/logging.dart";

import "package:quiver/collection.dart";

export 'package:redstone_mapper/mapper.dart';
export 'package:redstone_mapper/plugin.dart';
export 'package:redstone_mapper_mongo/service.dart';
export 'package:redstone_mapper_mongo/manager.dart';
export 'package:redstone_mapper_mongo/metadata.dart';
export 'package:redstone_web_socket/redstone_web_socket.dart';

export "package:redstone/server.dart" show
  Route, Group, Attr, Interceptor, QueryParam, ErrorHandler, DefaultRoute, Body, GET, POST, PUT, DELETE, ErrorResponse, RedstonePlugin, Manager, request, response, Install, Inject, Ignore, chain, JSON, FORM;

part "src/common/tokens.dart";

http.Client httpClient = new http.Client();

Logger logger = new Logger("Services");

Map<String, dynamic> config;

final Random random = new Random();

String template(String templateName, binding) {
  var file = new File("templates/${templateName}.mustache");
  
  if (!file.existsSync()) {
    throw new ArgumentError("Template does not exist.");
  }
  
  return render(file.readAsStringSync(), binding);
}

File www(String path) => new File("www/${path}");

void ServicesPlugin(Manager manager) {
}

void loadConfig() {
  var file = new File("config.json");

  if (!file.existsSync()) {
    file.writeAsStringSync("{}");
  }

  var content = file.readAsStringSync();

  config = JSON.decode(content);
}
