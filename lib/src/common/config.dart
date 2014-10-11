part of directcode.services.common;

Map<String, dynamic> config;

void loadConfig() {
  var file = new File("config.json");

  if (!file.existsSync()) {
    file.writeAsStringSync("{}");
  }

  var content = file.readAsStringSync();

  config = JSON.decode(content);
}