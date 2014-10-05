library directcode.services;

import "common.dart";
import "package:redstone/server.dart" as app;

@app.Install()
import "api.dart";

void startServices() {
  loadTokens();
  
  var dbManager = new MongoDbManager("mongodb://localhost/services", poolSize: 3);

  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(TokenPlugin);
  app.setupConsoleLog();
  app.start();
}
