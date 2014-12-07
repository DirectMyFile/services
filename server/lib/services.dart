library directcode.services;

import "common.dart";
import "package:redstone/server.dart" as app;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf.dart' as shelf;

@Install(urlPrefix: "/api")
import "api.dart";

@Install()
import "ui.dart";

void startServices() {
  loadConfig();
  
  var dbManager = new MongoDbManager("mongodb://localhost/services", poolSize: 3);

  app.addPlugin(ServicesPlugin);
  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(getWebSocketPlugin());
  app.setupConsoleLog();

  app.setShelfHandler(createStaticHandler("www/build/web/", defaultDocument: "index.html", serveFilesOutsidePath: false));
  
  var port = config.containsKey("port") ? config['port'] : 8080;

  app.start(port: port);
}

@app.Interceptor(r'/.*')
allowCORS() {
  if (app.request.method == "OPTIONS") {
    //overwrite the current response and interrupt the chain.
    app.response = new shelf.Response.ok(null, headers: _createCorsHeader());
    app.chain.interrupt();
  } else {
    //process the chain and wrap the response
    app.chain.next(() => app.response.change(headers: _createCorsHeader()));
  }
}

_createCorsHeader() => {"Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "*"};