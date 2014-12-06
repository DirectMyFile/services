library directcode.services;

import "common.dart";
import "package:redstone/server.dart" as app;

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

  var port = config.containsKey("port") ? config['port'] : 8080;

  app.start(port: port);
}
