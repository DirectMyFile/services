library directcode.services;

import "common.dart";
import "package:redstone/server.dart" as app;
import 'package:shelf_static/shelf_static.dart';

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
  app.chain.next(() => app.response.change(headers: _createCorsHeader()));
}

_createCorsHeader() => {"Access-Control-Allow-Origin": "*"};