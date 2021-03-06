library directcode.services;

import "common.dart";
import "package:redstone/redstone.dart" as app;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf.dart' as shelf;

@Install(urlPrefix: "/api")
import "api.dart";

@Install()
import "ui.dart";

void startServices() {
  hierarchicalLoggingEnabled = true;
  logger.level = Level.INFO;
  logger.onRecord.listen((r) {
    print("[${r.loggerName}] ${r.message}");
    if (r.error != null) {
      print(r.error);
      print(r.stackTrace);
    }
  });
  logger.info("Loading Configuration");
  loadConfig();

  var dbManager = new MongoDbManager("mongodb://localhost/services", poolSize: 3);

  app.addPlugin(ServicesPlugin);
  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(getWebSocketPlugin());

  app.setShelfHandler(createStaticHandler("www/build/web/", defaultDocument: "index.html", serveFilesOutsidePath: false));

  var port = config.containsKey("port") ? config['port'] : 8080;

  logger.info("Starting");
  app.start(port: port);
}

@Interceptor(r"/.*")
handleCORS() async {
  if (request.method != "OPTIONS") {
    await chain.next();
  }
  return response.change(headers: _createCorsHeader());
}

_createCorsHeader() => {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "CONTENT-TYPE, X-DIRECTCODE-TOKEN"
};
