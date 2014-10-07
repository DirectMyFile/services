library directcode.services;

import "common.dart";
import "package:redstone/server.dart" as app;

import "package:logging/logging.dart";

@Install()
import "api.dart";

@Install()
import "ui.dart";

void startServices() {
  loadTokens();
  loadConfig();
  
  setupAPI();
  
  var dbManager = new MongoDbManager("mongodb://localhost/services", poolSize: 3);

  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(TokenPlugin);
  app.addPlugin(getWebSocketPlugin());
  app.addPlugin(ServicesPlugin);
  app.setupConsoleLog();
  
  var port = config.containsKey("port") ? config['port'] : 8080;
  
  app.start(port: port);
}
