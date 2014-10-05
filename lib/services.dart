library directcode.services;

import "dart:io";

import "dart:convert" show JSON;

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_mongo/service.dart';
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:redstone_mapper_mongo/metadata.dart';

import "package:redstone/server.dart" show
  Route, Group, Attr, Interceptor, QueryParam, ErrorHandler, DefaultRoute, Body, GET, POST, PUT, DELETE, ErrorResponse, RedstonePlugin, Manager;
import "package:redstone/server.dart" as app;

part "src/members.dart";
part "src/token.dart";

void startServices() {
  loadTokens();
  
  var dbManager = new MongoDbManager("mongodb://localhost/services", poolSize: 3);

  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(TokenPlugin);
  app.setupConsoleLog();
  app.start();
}

MongoDb get mongoDb => app.request.attributes.dbConn;

