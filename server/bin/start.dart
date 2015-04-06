import "dart:async";
import "dart:isolate";
import "dart:io";

import "package:services/services.dart" as services;

void start([message]) {
  services.startServices();
}

bool production = false;

main(List<String> args) async {
  production = args.contains("--production");

  if (production) {
    await runForever();
  } else {
    start();
  }
}

int startCount = 0;

runForever() async {
  Isolate isolate = await Isolate.spawn(start, null);
  startCount++;
  var rp = new ReceivePort();
  isolate.addOnExitListener(rp.sendPort);
  await rp.first;
  if (startCount < 5) {
    await runForever();
  } else {
    print("Major Error. Server stopped 5 times in a row.");
    exit(2);
  }
}
