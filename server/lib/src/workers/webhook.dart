library directcode.services.workers.webhook;

import "dart:convert";
import "package:http/http.dart" as http;
import "package:services/worker.dart";

http.Client client = new http.Client();
WorkerSocket socket;

void main(List<String> args, Worker worker) {
  print("[WebHook Worker] Started");
  
  socket = worker.createSocket();
  
  socket.listen((value) {
    if (value is WebHookExecution) {
      client.post(value.url, body: JSON.encode(data), headers: {
        "X-DirectCode-WebHook": value.hookId,
        "X-DirectCode-Event": value.eventId
      }).then((response) {
      }).catchError((e) {
      });
    }
  });
  
  socket.done.then((_) {
    print("[WebHook Worker] Stopped");
  });
}

class WebHookExecution {
  String event;
  Map data;
  String hookId;
  String eventId;
  String url;
}