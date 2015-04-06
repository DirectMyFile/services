import "package:services/services.dart" as services;

void start() {
  services.startServices();
}

bool production = false;

void main(List<String> args) {
  production = args.contains("--production");
  start();
}
