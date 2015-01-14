import "dart:html";
import "dart:convert";
import "package:polymer/polymer.dart";

void main() {
  initPolymer();
}

@CustomTag("services-event-stats")
class ServicesEventStats extends PolymerElement {
  @observable List<Listener> listeners = [];
  
  ServicesEventStats.created() : super.created();
  
  @override
  void attached() {
    HttpRequest.getString("/api/events/stats").then((value) {
      var json = JSON.decode(value);
      listeners = json["listeners"].keys.map((it) {
        return new Listener()..name = it..count = json["listeners"][it];
      }).toList();
    });
  }
}

class Listener {
  String name;
  int count;
}